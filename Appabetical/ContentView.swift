//
//  ContentView.swift
//  Appabetical
//
//  Created by Rory Madden on 5/12/22.
//

import SwiftUI
import MobileCoreServices

let fm = FileManager.default
let plistUrl = URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist")
let plistUrlBkp = URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist.bkp")
let plistUrlNew = URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist.new")
let savedLayoutUrl = URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist.saved")
let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let iconsOnAPage = 24 // iPads are either 20 or 30 I believe... no support yet

struct ContentView: View {
    // Sort the selected pages
    func sortPage() {
        // Back up IconState normally
        do {
            if fm.fileExists(atPath: plistUrlBkp.path) {
                try fm.removeItem(at: plistUrlBkp)
            }
            try fm.copyItem(at: plistUrl, to: plistUrlBkp)
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
            return
        }
        
        // Open IconState.plist
        guard var plist = NSDictionary(contentsOf: plistUrl) as? [String:AnyObject] else { return }
        guard let iconLists = plist["iconLists"] as? [[AnyObject]] else { return }
//        let today = plist["today"] as? [[String:AnyObject]] ?? [[String:AnyObject]]()
        var newIconLists = [[AnyObject]]()
        for i in 0 ... iconLists.count - 1 {
            newIconLists.append(iconLists[i])
        }
//        var newToday = [[String:AnyObject]]()
//        for i in 0 ... today.count - 1 {
//            newToday.append(today[i])
//        }
        
        // If we are sorting across pages TODO implement check
        if pageOp == PageOptions.acrossPages {
            newIconLists[selectedItems[0] - 1] = []
            for i in selectedItems {
                newIconLists[selectedItems[0] - 1] += iconLists[i - 1]
            }
            for i in selectedItems.reversed() {
                if i == selectedItems[0] {
                    break
                }
                newIconLists.remove(at: i - 1)
            }
            selectedItems = [selectedItems[0]]
        }
        
        // Sort each selected page
        for i in selectedItems {
            let chosen = newIconLists[i - 1]
            var newChosen = chosen
            
            if sortOp == SortOptions.alpha {
                // Sort the names
                newChosen.sort(by: {(o1,o2) in compareByType(object1: o1, object2: o2, folderOp: folderOp)})
            } else if sortOp == SortOptions.colour {
                // TODO strange bug here that occurs if a Hue sort is run any time other than the first time. Possible memory issue? Current "fix" is respringing after any sort.
                
                // Sort by colour
                newChosen.sort(by: { (o1, o2) in return compareByTypeColor(object1: o1, object2: o2, folderOp: folderOp)})
            }
            newIconLists[i - 1] = newChosen
        }
        
        // Evenly distribute icons amongst pages to avoid overflow
        if pageOp == PageOptions.acrossPages {
            var newNewIconLists = [[AnyObject]]() // great variable naming!!!!!
            for page in newIconLists {
                var pageSize = 0
                var pageNew = [AnyObject]()
                for item in page {
                    let itemSize = getItemSize(item: item).rawValue
                    if pageSize == iconsOnAPage {
                        pageSize = 0
                        newNewIconLists.append(pageNew)
                        pageNew.removeAll()
                    }
                    if pageSize + itemSize > iconsOnAPage {
                        newNewIconLists.append(pageNew)
                        pageNew.removeAll()
                        pageSize = 0
                    }
                    pageNew.append(item)
                    pageSize += itemSize
                }
                newNewIconLists.append(pageNew)
            }
            plist["iconLists"] = newNewIconLists as AnyObject
        } else {
            plist["iconLists"] = newIconLists as AnyObject
        }
        
        // Save and validate the new file
        (plist as NSDictionary).write(to: plistUrlNew, atomically: true)
        let (valid, error) = validateIconState(old: plistUrl, new: plistUrlNew)
        if valid {
            do {
                try fm.replaceItemAt(plistUrl, withItemAt: plistUrlNew)
            } catch {
                UIApplication.shared.alert(body: error.localizedDescription)
                return
            }
        } else {
            UIApplication.shared.alert(body: "New IconState appears to be corrupt. Sorting has been aborted, and no system files have been edited. Specific error: \(error). Please screenshot and report.")
            return
        }
        
//        respring()
    }
    
    // Settings variables
    @State private var selectedItems = [Int]()
    @State private var pageOp = PageOptions.individually
    @State private var folderOp = FolderOptions.noSort
    @State private var sortOp = SortOptions.alpha
    
    @Environment(\.openURL) var openURL

    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: {
                        MultiSelectPickerView(allItems: [Int](1...getNumPages()), selectedItems: $selectedItems, pageOp: $pageOp).navigationBarTitle("", displayMode: .inline)
                    }, label: {
                        HStack {
                            Text("Select Pages")
                            Spacer()
                            Text(selectedItems.map { String($0) }.joined(separator: ", ")).foregroundColor(.secondary)
                        }
                    })
                    Picker("Ordering", selection: $sortOp) {
                        Text("A-Z").tag(SortOptions.alpha)
                        Text("Colour").tag(SortOptions.colour)
                    }.onChange(of: sortOp, perform: {nv in if nv == .colour && folderOp == .alongside { folderOp = .separately }})
                    Picker("Pages", selection: $pageOp) {
                        Text("Sort pages independently").tag(PageOptions.individually)
                        if areNeighbouring(pages: selectedItems) {
                            Text("Sort apps across pages").tag(PageOptions.acrossPages)
                        }
                    }
                    Picker("Folders", selection: $folderOp) {
                        Text("Retain current order").tag(FolderOptions.noSort)
                        if (sortOp == .alpha) {
                            Text("Sort along with apps").tag(FolderOptions.alongside)
                        }
                        Text("Sort separate from apps").tag(FolderOptions.separately)
                    }
                    Button("Sort Apps") {
                        sortPage()
                    }.disabled(selectedItems.isEmpty)
                }
                Section (footer: fm.fileExists(atPath: savedLayoutUrl.path) ? Text("The previously saved layout will be overwritten.") : Text("It is recommended you save your current layout before experimenting as only one undo is possible.")) {
                    Button("Undo Last Sort") {
                        restoreBackup()
                    }.disabled(!fm.fileExists(atPath: plistUrlBkp.path))
                    Button("Restore Saved Layout") {
                        restoreLayout()
                    }.disabled(!fm.fileExists(atPath: savedLayoutUrl.path))
                    Button("Back Up Current Layout") {
                        saveLayout()
                    }
                }
            }.navigationTitle("Appabetical")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        openURL(URL(string: "https://github.com/nutmeg-5000/Appabetical")!)
                    }) {
                        Image("github")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        openURL(URL(string: "https://ko-fi.com/avangelista")!)
                    }) {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
