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

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}

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
    
    // Open updates page
    func openGithub() {
        if let url = URL(string: "https://github.com/nutmeg-5000/Appabetical/releases") {
            UIApplication.shared.open(url)
        }
    }
    
    func getTimeSaved(url: URL) -> String {
        if fm.fileExists(atPath: url.path) {
            do {
                let attributes = try fm.attributesOfItem(atPath: url.path)
                if let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let modificationDateString = dateFormatter.string(from: modificationDate)
                    return modificationDateString
                }
            } catch {
                errorMsg = error.localizedDescription
            }
        }
        return "(unknown)"
    }
    
    // Save a homescreen backup manually
    func saveLayout() {
        do {
            if fm.fileExists(atPath: savedLayoutUrl.path) {
                try fm.removeItem(at: savedLayoutUrl)
            }
            try fm.copyItem(at: plistUrl, to: savedLayoutUrl)
            UIApplication.shared.alert(title: "Layout Saved", body: "Layout has been saved successfully.")
        } catch {
            errorMsg = error.localizedDescription
            return
        }
    }
    
    // Restore the manual homescreen backup
    func restoreLayout() {
        UIApplication.shared.confirmAlert(title: "Confirm Restore", body: "This layout was saved on \(getTimeSaved(url: savedLayoutUrl)). Be mindful if you've added any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
            do {
                try fm.replaceItemAt(plistUrl, withItemAt: savedLayoutUrl)
                try fm.copyItem(at: plistUrl, to: savedLayoutUrl)
                if fm.fileExists(atPath: plistUrlBkp.path) {
                    try fm.removeItem(at: plistUrlBkp)
                }
            } catch {
                errorMsg = error.localizedDescription
                return
            }

            respring()
        }, noCancel: false)
    }
    
    // Restore the latest backup
    func restoreBackup() {
        UIApplication.shared.confirmAlert(title: "Confirm Undo", body: "This layout was saved on \(getTimeSaved(url: plistUrlBkp)). Be mindful if you've added any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
            do {
                try fm.replaceItemAt(plistUrl, withItemAt: plistUrlBkp)
            } catch {
                errorMsg = error.localizedDescription
                return
            }

            respring()
        }, noCancel: false)
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
                    }
                    Picker("Pages", selection: $pageOp) {
                        Text("Sort pages independently").tag(PageOptions.individually)
                        if areNeighbouring(pages: selectedItems) {
                            Text("Sort apps across pages").tag(PageOptions.acrossPages)
                        }
                    }
                    Picker("Folders", selection: $folderOp) {
                        Text("Retain current order").tag(FolderOptions.noSort)
                        Text("Sort along with apps").tag(FolderOptions.alongside)
                        Text("Sort separate from apps").tag(FolderOptions.separately)
                    }
                    Button("Sort Apps") {
                        sortPage()
                    }.disabled(selectedItems.isEmpty)
//                    Toggle(isOn: $yesRespring) {
//                        Text("Respring Afterwards")
//                    }
                    if !errorMsg.isEmpty {
                        Text("Error: \(errorMsg)").foregroundColor(.red)
                    }
                }
                Section (footer: fm.fileExists(atPath: savedLayoutUrl.path) ? Text("The previously saved layout will be overwritten.") : Text("It is recommended you save your current layout before experimenting.")) {
                    if fm.fileExists(atPath: plistUrlBkp.path) {
                        Button("Undo Last Sort") {
                            restoreBackup()
                        }.foregroundColor(.red)
                    }
                    if fm.fileExists(atPath: savedLayoutUrl.path) {
                        Button("Restore Saved Layout") {
                            restoreLayout()
                        }.foregroundColor(.red)
                    }
                    Button("Back Up Current Layout") {
                        saveLayout()
                    }
                }
                if fm.fileExists(atPath: plistUrlBkp.path) {
                    Button("Undo Last Sort") {
                        restoreBackup()
                    }.foregroundColor(.red)
                }
                Section (footer: Text("Appabetical version \(version) by Avangelista")) {
                    Button("Check for Updates") {
                        openGithub()
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
