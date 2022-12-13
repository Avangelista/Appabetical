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
let savedLayourUrl = URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist.saved")
let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

// Check if all selected pages are neighbouring
func areNeighbouring(pages: Array<Int>) -> Bool {
    if pages.isEmpty {
        return true
    }
    for i in 1..<pages.count {
        if pages[i] - pages[i - 1] > 1 {
            return false
        }
    }
    return true
}

struct ContentView: View {
    // Respring the device if enabled
    func respring() {
        if yesRespring {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                guard let window = UIApplication.shared.windows.first else { return }
                while true {
                    window.snapshotView(afterScreenUpdates: false)
                }
            }
        }
    }
    
    // Save a homescreen backup manually
    func saveLayout() {
        do {
            if fm.fileExists(atPath: savedLayourUrl.path) {
                try fm.removeItem(at: savedLayourUrl)
            }
            try fm.copyItem(at: plistUrl, to: savedLayourUrl)
        } catch {
            errorMsg = error.localizedDescription
            return
        }
        
        layoutSavedSuccessfully = true
    }
    
    // Restore the manual homescreen backup
    func restoreLayout() {
        do {
            try fm.replaceItemAt(plistUrl, withItemAt: savedLayourUrl)
            try fm.copyItem(at: plistUrl, to: savedLayourUrl)
            if fm.fileExists(atPath: plistUrlBkp.path) {
                try fm.removeItem(at: plistUrlBkp)
            }
        } catch {
            errorMsg = error.localizedDescription
            return
        }

        respring()
    }
    
    // Restore the latest backup
    func restoreBackup() {
        do {
            try fm.replaceItemAt(plistUrl, withItemAt: plistUrlBkp)
        } catch {
            errorMsg = error.localizedDescription
            return
        }

        respring()
    }
    
    // Get the number of pages on the user's home screen TODO check when sorting too
    func getNumPages() -> Int {
        let plist = NSDictionary(contentsOf: plistUrl) as! Dictionary<String, AnyObject>
        let iconLists = plist["iconLists"] as! Array<Array<AnyObject>>
        return iconLists.count
    }
    
    // Sort the selected pages
    func sortPage() {
        // Back up IconState normally
        do {
            if fm.fileExists(atPath: plistUrlBkp.path) {
                try fm.removeItem(at: plistUrlBkp)
            }
            try fm.copyItem(at: plistUrl, to: plistUrlBkp)
        } catch {
            errorMsg = error.localizedDescription
            return
        }
        
        let au = AppUtils.shared
        
        // Open IconState.plist
        var plist = NSDictionary(contentsOf: plistUrl) as! Dictionary<String, AnyObject>
        let iconLists = plist["iconLists"] as! Array<Array<AnyObject>>
        var newIconLists = [Array<AnyObject>]()
        for i in 0 ... iconLists.count - 1 {
            newIconLists.append(iconLists[i])
        }
        
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
                
                // Get dominant colours of all icons
                var idToColor = [String: UIColor]()
                for c in newChosen {
                    if c is String {
                        let cs = c as! String
                        idToColor[cs] = au.getIcon(id: cs).mergedColor()
                    }
                }
                
                // Sort by colour
                newChosen.sort(by: { (o1, o2) in return compareByTypeColor(object1: o1, object2: o2, colorArray: idToColor)})
            }
            newIconLists[i - 1] = newChosen
        }
        plist["iconLists"] = newIconLists as AnyObject
        
        // Save and validate the new file
        (plist as NSDictionary).write(to: plistUrlNew, atomically: true)
        if validateIconState(old: plistUrl, new: plistUrlNew) {
            do {
                try fm.replaceItemAt(plistUrl, withItemAt: plistUrlNew)
            } catch {
                errorMsg = error.localizedDescription
                return
            }
        } else {
            errorMsg = "New IconState appears to be corrupt. Sorting has been aborted, and no system files have been edited."
            return
        }
        
        respring()
    }
    
    // Settings variables
    @State private var selectedItems = [Int]()
    @State private var pageOp = PageOptions.individually
    @State private var folderOp = FolderOptions.noSort
    @State private var sortOp = SortOptions.alpha
    @State private var yesRespring = true
    @State private var errorMsg = ""
    @State private var layoutSavedSuccessfully = false
    
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
                }
                Section (footer: Text("Choose how folders on the homescreen should be sorted relative to other apps.")) {
                    Picker("Ordering Options", selection: $sortOp) {
                        Text("Sort A-Z").tag(SortOptions.alpha)
                        Text("Sort by hue").tag(SortOptions.colour)
                    }
                    Picker("Page Options", selection: $pageOp) {
                        Text("Sort independently").tag(PageOptions.individually)
                        if areNeighbouring(pages: selectedItems) {
                            Text("Sort across pages").tag(PageOptions.acrossPages)
                        }
                    }
                    Picker("Folder Options", selection: $folderOp) {
                        Text("Retain current order").tag(FolderOptions.noSort)
                        Text("Sort in with apps").tag(FolderOptions.alongside)
                        Text("Sort separately").tag(FolderOptions.separately)
                    }
                }
                Section {
                    Button("Sort Apps") {
                        sortPage()
                    }.disabled(selectedItems.isEmpty)
                    Toggle(isOn: $yesRespring) {
                        Text("Respring Afterwards")
                    }
                    if !errorMsg.isEmpty {
                        Text("Error: \(errorMsg)").foregroundColor(.red)
                    }
                }
                Section (footer: Text("Back up the current homescreen layout - note that any previous backup will be overwritten.")) {
                    if fm.fileExists(atPath: savedLayourUrl.path) {
                        Button("Restore Saved Layout") {
                            restoreLayout()
                        }
                    }
                    Button("Back Up Current Layout") {
                        saveLayout()
                    }
                    if layoutSavedSuccessfully {
                        Text("Layout saved!").foregroundColor(.secondary)
                    }
                }
                if fm.fileExists(atPath: plistUrlBkp.path) {
                    Section (footer: Text("Undo the most recent sort - note that only one undo is possible, it's recommended you save your preferred layout using the \"Back Up Current Layout\" button above.")) {
                        Button("Undo Last Sort") {
                            restoreBackup()
                        }.foregroundColor(.red)
                        
                    }
                }
                Section (footer: Text("Appabetical version \(version) by Avangelista")) {
                    Button("Check for Updates") {
                        
                    }
                }
            }.navigationTitle("Appabetical")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
