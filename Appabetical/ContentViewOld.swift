////
////  ContentView.swift
////  Appabetical
////
////  Created by Rory Madden on 5/12/22.
////
//
//import SwiftUI
//import MobileCoreServices
//
//let fm = FileManager.default
//
//let plistUrl = {
//#if targetEnvironment(simulator)
//    Bundle.main.url(forResource: "IconState", withExtension: "plist")!
//#else
//    URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist")
//#endif
//}()
//
//let plistUrlBkp = {
//#if targetEnvironment(simulator)
//    Bundle.main.url(forResource: "IconState.plist", withExtension: "bkp")!
//#else
//    URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist.bkp")
//#endif
//}()
//
//let plistUrlOG = {
//#if targetEnvironment(simulator)
//    Bundle.main.url(forResource: "IconState.plist", withExtension: "orig")!
//#else
//    URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist.orig")
//#endif
//}()
//
//let plistUrlNew = {
//#if targetEnvironment(simulator)
////    Bundle.main.url(forResource: "IconState.plist", withExtension: "new")!
//    fm.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("IconStateNew.plist")
//#else
//    URL(fileURLWithPath: "/var/mobile/Library/SpringBoard/IconState.plist.new")
//#endif
//}()
//
//// Options for sorting pages
//enum PageOptions: String, CaseIterable, Identifiable {
//    case individually
//    case acrossPages
//    var id: String { self.rawValue }
//}
//
//// Options for sorting folders
//enum FolderOptions: String, CaseIterable, Identifiable {
//    case noSort
//    case alongside
//    case separately
//    var id: String { self.rawValue }
//}
//
//// Options for type of sort to use
//enum SortOptions: String, CaseIterable, Identifiable {
//    case alpha
//    case colour
//    var id: String { self.rawValue }
//}
//
//// Check if all selected pages are neighbouring
//func areNeighbouring(pages: Array<Int>) -> Bool {
//    if pages.isEmpty {
//        return true
//    }
//    for i in 1..<pages.count {
//        if pages[i] - pages[i - 1] > 1 {
//            return false
//        }
//    }
//    return true
//}
//
//// Custom multi-select picker
//// https://www.simplykyra.com/2022/02/23/how-to-make-a-custom-picker-with-multi-selection-in-swiftui/
//struct MultiSelectPickerView: View {
//    @State var allItems: [Int]
//    @Binding var selectedItems: [Int]
//    @Binding var pageOp: PageOptions
//
//    var body: some View {
//        Form {
//            List {
//                Section(header: Text("Pages")) {
//                    ForEach(allItems, id: \.self) { item in
//                        Button(action: {
//                            withAnimation {
//                                if self.selectedItems.contains(item) {
//                                    self.selectedItems.removeAll(where: { $0 == item })
//                                } else {
//                                    self.selectedItems.append(item)
//                                }
//                                self.selectedItems.sort()
//                                if !areNeighbouring(pages: self.selectedItems) {
//                                    self.pageOp = PageOptions.individually // bug here
//                                }
//                            }
//                        }) {
//                            HStack {
//                                Image(systemName: "checkmark")
//                                    .opacity(self.selectedItems.contains(item) ? 1.0 : 0.0)
//                                Text("Page \(String(item))")
//                            }
//                        }
//                        .foregroundColor(.primary)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ContentView: View {
//
//    // DEBUG: Keep track of any errors
//    @State var errorMsg = ""
//
//    // Respring the device if enabled
//    func respring() {
//#if targetEnvironment(simulator)
//        print("Respring!")
//#else
//        if yesRespring {
//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//                guard let window = UIApplication.shared.windows.first else { return }
//                while true {
//                    window.snapshotView(afterScreenUpdates: false)
//                }
//            }
//        }
//#endif
//    }
//
//    // Restore the latest backup
//    func restoreBackup() {
//        do {
//            if fm.fileExists(atPath: plistUrl.path) {
//                try fm.removeItem(at: plistUrl)
//            }
//            try fm.copyItem(at: plistUrlBkp, to: plistUrl)
//        } catch {
//            print(error.localizedDescription)
//            errorMsg = error.localizedDescription
//            return
//        }
//
//        respring()
//    }
//
//    // Restore the OG
//    func restoreOG() {
//        do {
//            if fm.fileExists(atPath: plistUrl.path) {
//                try fm.removeItem(at: plistUrl)
//            }
//            try fm.copyItem(at: plistUrlOG, to: plistUrl)
//        } catch {
//            print(error.localizedDescription)
//            errorMsg = error.localizedDescription
//            return
//        }
//
//        respring()
//    }
//
//    // Get the number of pages on the user's home screen TODO check when sorting too
//    func getNumPages() -> Int {
//        let plist = NSDictionary(contentsOf: plistUrl) as! Dictionary<String, AnyObject>
//        let iconLists = plist["iconLists"] as! Array<Array<AnyObject>>
//        return iconLists.count
//    }
//
//    // Sort the selected pages
//    func sortPage() {
//#if targetEnvironment(simulator)
//
//#else
//        // Make OG backup of IconState if it doesn't exist
//        do {
//            if !fm.fileExists(atPath: plistUrlOG.path) {
//                try fm.copyItem(at: plistUrl, to: plistUrlOG)
//            }
//        } catch {
//            print(error.localizedDescription)
//            return
//        }
//
//        // Back up IconState normally
//        do {
//            if fm.fileExists(atPath: plistUrlBkp.path) {
//                try fm.removeItem(at: plistUrlBkp)
//            }
//            try fm.copyItem(at: plistUrl, to: plistUrlBkp)
//        } catch {
//            print(error.localizedDescription)
//            errorMsg = error.localizedDescription
//            return
//        }
//#endif
//        // Dict to convert app ID to name
//        let apps = LSApplicationWorkspace.default().allApplications() ?? []
//        var idToApp = [String: String]()
//        var idToIcon = [String: URL]()
//        var idToUrl = [String: URL]()
//        var idToAssets = [String: URL]()
//        for app in apps {
//            idToApp[app.applicationIdentifier] = app.localizedName()
//            idToIcon[app.applicationIdentifier] = app.bundleURL.appendingPathComponent("Info.plist")
//            idToUrl[app.applicationIdentifier] = app.bundleURL
//            idToAssets[app.applicationIdentifier] = app.bundleURL.appendingPathComponent("Assets.car")
//        }
//
//        // Open IconState.plist
//        var plist = NSDictionary(contentsOf: plistUrl) as! Dictionary<String, AnyObject>
//        let iconLists = plist["iconLists"] as! Array<Array<AnyObject>>
//
//        var newIconLists = [Array<AnyObject>]()
//        for i in 0 ... iconLists.count - 1 {
//            newIconLists.append(iconLists[i])
//        }
//
//        // If we are sorting across pages TODO implement check
//        if pageOp == PageOptions.acrossPages {
//            newIconLists[selectedItems[0] - 1] = []
//            for i in selectedItems {
//                newIconLists[selectedItems[0] - 1] += iconLists[i - 1]
//            }
//            for i in selectedItems.reversed() {
//                if i == selectedItems[0] {
//                    break
//                }
//                newIconLists.remove(at: i - 1)
//            }
//            selectedItems = [selectedItems[0]]
//        }
//
//        // Sort each selected page
//        for i in selectedItems {
//            let chosen = iconLists[i - 1]
//            var newChosen = [String]()
//            var widgetsEtc = [Dictionary<String, AnyObject>]()
//            for thing in chosen {
//                if thing is String {
//                    newChosen.append(thing as! String)
//                } else if thing is Dictionary<String, AnyObject> {
//                    widgetsEtc.append(thing as! Dictionary<String, AnyObject>)
//                }
//            }
//
//            // Sort the names
//            if sortOp == SortOptions.alpha {
//                newChosen.sort { (lhs: String, rhs: String) -> Bool in
//                    return idToApp[lhs]!.lowercased() < idToApp[rhs]!.lowercased()
//                }
//            } else if sortOp == SortOptions.colour {
//                var idToColor = [String: UIColor]()
//
//                // Get dominant colours of all icons
//                for c in newChosen {
//                    idToColor[c] = UIColor.black
//                    let iconUrl = idToIcon[c]!
//                    if fm.fileExists(atPath: iconUrl.path) {
//                        let infoPlist = NSDictionary(contentsOf: iconUrl) as! Dictionary<String, AnyObject>
//                        if infoPlist.keys.contains("CFBundleIconFiles") {
//                            // This seems to only occur when there is no assets.car
//                            let iconFiles = infoPlist["CFBundleIconFiles"] as! Array<String>
//                            let iconName = iconFiles[0]
//                            var iconFile = ""
//                            // Get from root
//                            if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + ".png").path) {
//                                iconFile = iconName + ".png"
//                            } else if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + "@2x.png").path) {
//                                iconFile = iconName + "@2x.png"
//                            } else if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + "-large.png").path) {
//                                iconFile = iconName + "-large.png"
//                            } else if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + "@23.png").path) {
//                                iconFile = iconName + "@23.png"
//                            } else if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + "@3x.png").path) {
//                                iconFile =app.localizedName() iconName + "@3x.png"
//                            }
//
//                            if iconFile != "" {
//                                let theIconUrl = (idToUrl[c]?.appendingPathComponent(iconFile))!
//                                do {
//                                    let imgData = try Data(contentsOf: theIconUrl)
//                                    let image = UIImage(data: imgData)!
//                                    idToColor[c] = image.mergedColor()
//                                    fieldText += theIconUrl.path
//                                } catch {
//                                    print(error.localizedDescription)
//                                    errorMsg = error.localizedDescription
//                                    idToColor[c] = UIColor.black
//                                }
//                            } else {
//                                idToColor[c] = UIColor.black
//                            }
////                            iconPng = iconFiles[0] + ".png"
////                            let theIconUrl = (idToUrl[c]?.appendingPathComponent(iconPng))!
////                            do {
////                                let imgData = try Data(contentsOf: theIconUrl)
////                                let image = UIImage(data: imgData)!
////                                idToColor[c] = image.mergedColor()
////                                fieldText += theIconUrl.path
////                            } catch {
////                                print(error.localizedDescription)
////                                errorMsg = error.localizedDescription
////                                idToColor[c] = UIColor.black
////                            }
//                        } else if infoPlist.keys.contains("CFBundleIcons") {
//                            let icons = infoPlist["CFBundleIcons"] as! Dictionary<String, AnyObject>
//                            if icons.keys.contains("CFBundlePrimaryIcon") {
//                                let primaryIcon = icons["CFBundlePrimaryIcon"] as! Dictionary<String, AnyObject>
////                                if primaryIcon.keys.contains("CFBundleIconName") {
////                                    let iconName = primaryIcon["CFBundleIconName"] as! String
////                                    // Get from assets.car
////                                    let assetsBundle = Bundle(url: idToAssets[c]!)
////                                    let appIconImage = UIImage(named: iconName, in: assetsBundle, compatibleWith: nil)
////                                    idToColor[c] = appIconImage!.mergedColor()
//                                if primaryIcon.keys.contains("CFBundleIconFiles") {
//                                    let iconFiles = primaryIcon["CFBundleIconFiles"] as! Array<String>
//                                    let iconName = iconFiles[0]
//                                    var iconFile = ""
//                                    // Get from root
//                                    if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + ".png").path) {
//                                        iconFile = iconName + ".png"
//                                    } else if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + "@2x.png").path) {
//                                        iconFile = iconName + "@2x.png"
//                                    } else if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + "-large.png").path) {
//                                        iconFile = iconName + "-large.png"
//                                    } else if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + "@23.png").path) {
//                                        iconFile = iconName + "@23.png"
//                                    } else if fm.fileExists(atPath: idToUrl[c]!.appendingPathComponent(iconName + "@3x.png").path) {
//                                        iconFile = iconName + "@3x.png"
//                                    }
//
//                                    if iconFile != "" {
//                                        let theIconUrl = (idToUrl[c]?.appendingPathComponent(iconFile))!
//                                        do {
//                                            let imgData = try Data(contentsOf: theIconUrl)
//                                            let image = UIImage(data: imgData)!
//                                            idToColor[c] = image.mergedColor()
//                                            fieldText += theIconUrl.path
//                                        } catch {
//                                            print(error.localizedDescription)
//                                            errorMsg = error.localizedDescription
//                                            idToColor[c] = UIColor.black
//                                        }
//                                    } else {
//                                        idToColor[c] = UIColor.black
//                                    }
//                                }
//                            }
//
//                        }
//
////                        let assetsBundle = Bundle(url: iconUrl)!
//
////                        let arrayName = "CFBundleIconFiles"
////                        let keyPath = "CFBundleIcons/CFBundlePrimaryIcon/CFBundleIconFiles"
////                        let plistPath = iconUrl.path
////                        let plistArray = NSArray(contentsOfFile: plistPath)!
////
////                        if let nestedArray = plistArray.value(forKeyPath: keyPath) as? [String] {
////                            fieldText += nestedArray[0]
////                        } else {
////                            fieldText += "Error"
////                        }
//
//
////                        if let iconFiles = assetsBundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
////                           let primaryIcon = iconFiles["CFBundlePrimaryIcon"] as? [String: Any],
////                           let primaryIconFileName = primaryIcon["CFBundleIconFiles"] as? [String] {
////                            let primaryIconFile = primaryIconFileName[0]
////                            let theIconUrl = (idToUrl[c]?.appendingPathComponent(primaryIconFile + ".png"))!
////                            do {
////                                let imgData = try Data(contentsOf: theIconUrl)
////                                let image = UIImage(data: imgData)!
////                                idToColor[c] = image.mergedColor()
////                            } catch {
////                                print(error.localizedDescription)
////                                errorMsg = error.localizedDescription
////                                idToColor[c] = UIColor.black
////                            }
////                        } else if let iconFiles = assetsBundle.object(forInfoDictionaryKey: "CFBundleIconFiles") as? [String] {
////                            let primaryIconFile = iconFiles[0]
////                            let theIconUrl = (idToUrl[c]?.appendingPathComponent(primaryIconFile + ".png"))!
////                            do {
////                                let imgData = try Data(contentsOf: theIconUrl)
////                                let image = UIImage(data: imgData)!
////                                idToColor[c] = image.mergedColor()
////                            } catch {
////                                print(error.localizedDescription)
////                                errorMsg = error.localizedDescription
////                                idToColor[c] = UIColor.black
////                            }
////                        } else {
////                            fieldText = c
////                            idToColor[c] = UIColor.black
////                        }
//
////                        do {
////                            let imgData = try Data(contentsOf: iconUrl)
////                            let image = UIImage(data: imgData)!
////                            idToColor[c] = image.mergedColor()
////                            let assetsBundle = Bundle(url: iconUrl)
////                            let appIconImage = UIImage(named: "AppIcon", in: assetsBundle, compatibleWith: nil)
////                            idToColor[c] = appIconImage!.mergedColor()
////                        } catch {
////                            print(error.localizedDescription)
////                            errorMsg = error.localizedDescription
////                            idToColor[c] = UIColor.black
////                        }
//                    } else {
//                        idToColor[c] = UIColor.black
//                    }
//                }
//
//                // Sort on colour
//                newChosen.sort { (c1: String, c2: String) -> Bool in
//                    var hue1: CGFloat = 0
//                    var saturation1: CGFloat = 0
//                    var brightness1: CGFloat = 0
//                    var alpha1: CGFloat = 0
//                    idToColor[c1]!.getHue(&hue1, saturation: &saturation1, brightness: &brightness1, alpha: &alpha1)
//
//                    var hue2: CGFloat = 0
//                    var saturation2: CGFloat = 0
//                    var brightness2: CGFloat = 0
//                    var alpha2: CGFloat = 0
//                    idToColor[c2]!.getHue(&hue2, saturation: &saturation2, brightness: &brightness2, alpha: &alpha2)
//
//                    if hue1 < hue2 {
//                        return true
//                    } else if hue1 > hue2 {
//                        return false
//                    }
//
//                    if saturation1 < saturation2 {
//                        return true
//                    } else if saturation1 > saturation2 {
//                        return false
//                    }
//
//                    if brightness1 < brightness2 {
//                        return true
//                    } else if brightness1 > brightness2 {
//                        return false
//                    }
//
//                    return true
//                }
//            }
//
//            var newPage = [AnyObject]()
//            newPage += widgetsEtc as [AnyObject]
//            newPage += newChosen as [AnyObject]
//
//            newIconLists[i - 1] = newPage
//        }
//
//        plist["iconLists"] = newIconLists as AnyObject
//
//        // Save the new file
//        do {
//            (plist as NSDictionary).write(to: plistUrlNew, atomically: true)
//            let input = try String(contentsOf: plistUrlNew)
//            print(input)
////            fieldText = input
//        } catch {
//            print(error.localizedDescription)
//            errorMsg = error.localizedDescription
//            return
//        }
//
//        respring()
//    }
//
//    // Settings variables
//    @State var selectedItems = [Int]()
//    @State private var pageOp = PageOptions.individually
//    @State private var folderOp = FolderOptions.noSort
//    @State private var sortOp = SortOptions.alpha
//    @State private var yesRespring = true
//    @State private var fieldText = "Nothing yet!"
//
//    var body: some View {
//        NavigationView {
//            List {
//                Section (footer: Text("To sort apps across mutliple pages, selected pages must be neighbouring. Otherwise, pages will be sorted independently.")) {
//                    NavigationLink(destination: {
//                        MultiSelectPickerView(allItems: [Int](1...getNumPages()), selectedItems: $selectedItems, pageOp: $pageOp).navigationBarTitle("", displayMode: .inline)
//                    }, label: {
//                        HStack {
//                            Text("Select Pages")
//                            Spacer()
//                            Text(selectedItems.map { String($0) }.joined(separator: ", ")).foregroundColor(.secondary)
//                        }
//                    })
//                }
//                Section (footer: Text("Choose how folders on the homescreen should be sorted relative to other apps.")) {
//                    Picker("Ordering Options", selection: $sortOp) {
//                        Text("Sort A-Z").tag(SortOptions.alpha)
//                        Text("Sort by hue").tag(SortOptions.colour)
//                    }
//                    Picker("Page Options", selection: $pageOp) {
//                        Text("Sort independently").tag(PageOptions.individually)
//                        if areNeighbouring(pages: selectedItems) {
//                            Text("Sort across pages").tag(PageOptions.acrossPages)
//                        }
//                    }
//                    Picker("Folder Options", selection: $folderOp) {
//                        Text("Don't sort").tag(FolderOptions.noSort)
//                        Text("Sort alongside apps").tag(FolderOptions.alongside)
//                        Text("Sort separately").tag(FolderOptions.separately)
//                    }
//                }
//                Section {
//                    Button("Sort Apps") {
//                        sortPage()
//                    }.disabled(selectedItems.isEmpty)
//                    Toggle(isOn: $yesRespring) {
//                        Text("Respring Afterwards")
//                    }
//                    if !errorMsg.isEmpty {
//                        Text("Error: \(errorMsg)")
//                    }
//                }
//#if targetEnvironment(simulator)
//                Section (footer: Text("Undo the most recent sort, or press and hold to restore your original homescreen layout from when the app was first installed.")) {
//                    Button(action: {}) {
//                        HStack {
//                            Text("Undo Last Sort")
//                            Spacer()
//                        }.contentShape(Rectangle())
//                    }
//                    .foregroundColor(.red)
//                    .simultaneousGesture(LongPressGesture().onEnded { _ in
//                        restoreOG()
//                    })
//                    .simultaneousGesture(TapGesture().onEnded {
//                        restoreBackup()
//                    })
//                    .buttonStyle(PlainButtonStyle())
//                }
//#else
//                if (fm.fileExists(atPath: plistUrlBkp.path)) {
//                    Section (footer: Text("Undo the most recent sort, or press and hold to restore your original homescreen layout from when the app was first installed.")) {
//                        Button(action: {}) {
//                            HStack {
//                                Text("Undo Last Sort")
//                                Spacer()
//                            }.contentShape(Rectangle())
//                        }
//                        .foregroundColor(.red)
//                        .simultaneousGesture(LongPressGesture().onEnded { _ in
//                            restoreOG()
//                        })
//                        .simultaneousGesture(TapGesture().onEnded {
//                            restoreBackup()
//                        })
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//#endif
//                Section (header: Text("IconState.plist preview")) {
//                    TextEditor(text: $fieldText)
//                }
//            }.navigationTitle("Appabetical")
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
