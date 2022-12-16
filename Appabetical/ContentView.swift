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
let webClipFolderUrl = URL(fileURLWithPath: "/var/mobile/Library/WebClips/")
let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let iconsOnAPage = 24 // iPads are either 20 or 30 I believe... no support yet

struct ContentView: View {
    // Sort the selected pages
    func sortPage() {
        makeBackup()
        
        // Open IconState.plist
        guard var plist = NSDictionary(contentsOf: plistUrl) as? [String:AnyObject] else { return }
        guard let iconLists = plist["iconLists"] as? [[AnyObject]] else { return }
        
        // Make sure the user hasn't selected a page, then adjusted their home screen before pressing Sort
        selectedItems = selectedItems.filter {$0 - 1 < iconLists.count}
        if selectedItems.isEmpty { return }
        
        var newIconLists = [[AnyObject]]()
        for i in 0 ... iconLists.count - 1 {
            newIconLists.append(iconLists[i])
        }
        
        // If we are sorting across pages
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
                newChosen.sort(by: { (o1, o2) in compareByType(object1: o1, object2: o2, folderOp: folderOp) })
            } else if sortOp == SortOptions.colour {
                // Sort by colour
                newChosen.sort(by: { (o1, o2) in compareByTypeColor(object1: o1, object2: o2, folderOp: folderOp) })
            }
            newIconLists[i - 1] = newChosen
        }
        
        // Evenly distribute icons amongst pages to avoid overflow
        var pageCount: Int
        if pageOp == PageOptions.acrossPages {
            var newNewIconLists = [[AnyObject]]() // great variable naming!!!!!
            for page in newIconLists {
                var pageSize = 0
                var pageNew = [AnyObject]()
                for item in page {
                    let itemSize = getItemSize(item: item).rawValue
                    if pageSize + itemSize > iconsOnAPage {
                        pageSize = 0
                        newNewIconLists.append(pageNew)
                        pageNew.removeAll()
                    }
                    pageNew.append(item)
                    pageSize += itemSize
                }
                newNewIconLists.append(pageNew)
            }
            plist["iconLists"] = newNewIconLists as AnyObject
            pageCount = newNewIconLists.count
        } else {
            plist["iconLists"] = newIconLists as AnyObject
            pageCount = newIconLists.count
        }
        
        // Show all hidden pages
        plist["listMetadata"] = nil
        
        // Generate new UUIDs for pages
        var newUUIDs = [String]()
        for _ in 0..<pageCount {
            newUUIDs.append(UUID().uuidString)
        }
        plist["listUniqueIdentifiers"] = newUUIDs as AnyObject
        
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
            UIApplication.shared.alert(body: "New IconState appears to be invalid. Sorting has been aborted, and no system files have been edited. Specific error: \(error). Please screenshot and report.")
            return
        }
        respring()
    }
    
    // Settings variables
    @State private var selectedItems = [Int]()
    @State private var pageOp = PageOptions.individually
    @State private var folderOp = FolderOptions.noSort
    @State private var sortOp = SortOptions.alpha
    @State private var widgetOp = WidgetOptions.top
    
    @Environment(\.openURL) var openURL

    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: {
                        MultiSelectPickerView(pages: getPages(), selectedItems: $selectedItems, pageOp: $pageOp).navigationBarTitle("", displayMode: .inline)
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
                            Text("Sort mixed with apps").tag(FolderOptions.alongside)
                        }
                        Text("Sort separate from apps").tag(FolderOptions.separately)
                    }
                    Picker("Widgets", selection: $widgetOp) {
                        Text("Move to top").tag(WidgetOptions.top)
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
                // Credit to SourceLocation
                // https://github.com/sourcelocation/AirTroller/blob/main/AirTroller/ContentView.swift
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        openURL(URL(string: "https://github.com/Avangelista/Appabetical")!)
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
