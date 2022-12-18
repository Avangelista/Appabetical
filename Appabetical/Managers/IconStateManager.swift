//
//  IconStateManager.swift
//  Appabetical
//
//  Created by exerhythm on 17.12.2022.
//

import Foundation

public class IconStateManager {
    
    static var shared = IconStateManager()
    
    public enum PageSortingOption {
        case individually
        case acrossPages
    }
    
    // Options for sorting folders
    public enum FolderSortingOption {
        case noSort
        case alongside
        case separately
    }
    
    // Options for type of sort to use
    public enum SortOption: Equatable {
        case alphabetically
        case color // swift language standart is US English :troll:
    }
    
    public func pageCount() throws -> Int {
        guard let plist = NSDictionary(contentsOf: plistUrl) as? [String:AnyObject] else { throw "no iconstate" }
        guard let iconLists = plist["iconLists"] as? [[AnyObject]] else { throw "no iconlists?" }
        return iconLists.count
    }
    
    public func sortPages(selectedPages: [Int], sortOption: SortOption, pageSortingOption: PageSortingOption, folderSortingOption: FolderSortingOption) throws {
        try BackupManager.makeBackup()
        
        // Open IconState.plist
        guard var plist = NSDictionary(contentsOf: plistUrl) as? [String:AnyObject] else { return }
        guard let iconLists = plist["iconLists"] as? [[AnyObject]] else { return }
        
        var springBoardItemsFlattened = (pageSortingOption == .acrossPages ?
                                         [iconLists.reduce([], +).map { SpringBoardItem(from: $0) }] :
                                            iconLists.map { $0.map { SpringBoardItem(from: $0) } }
        )
        
        // Sort each selected page
        springBoardItemsFlattened = springBoardItemsFlattened.map {
            $0.sorted { item1, item2 in
                item1.compare(to: item2, folderSortingOption: folderSortingOption, sortingOption: sortOption)
            }
        }
        
//        // Evenly distribute icons amongst pages to avoid overflow
//        var pageCount: Int
//        if pageSortingOption == .acrossPages {
//            var newNewIconLists = [[AnyObject]]() // great variable naming!!!!!
//            for page in springBoardItemsFlattened {
//                var pageSize = 0
//                var pageNew = [AnyObject]()
//                for item in page {
//                    let itemSize = item.widgetSize?.rawValue ?? 0
//                    if pageSize + itemSize > iconsOnAPage {
//                        pageSize = 0
//                        newNewIconLists.append(pageNew)
//                        pageNew.removeAll()
//                    }
//                    pageNew.append(item)
//                    pageSize += itemSize
//                }
//                newNewIconLists.append(pageNew)
//            }
//            plist["iconLists"] = newNewIconLists as AnyObject
//            pageCount = newNewIconLists.count
//        } else {
//            plist["iconLists"] = newIconLists as AnyObject
//            pageCount = newIconLists.count
//        }
//
//        // Show all hidden pages
//        plist["listMetadata"] = nil
//
//        // Generate new UUIDs for pages
//        var newUUIDs = [String]()
//        for _ in 0..<pageCount {
//            newUUIDs.append(UUID().uuidString)
//        }
//        plist["listUniqueIdentifiers"] = newUUIDs as AnyObject
//
//        // Save and validate the new file
//        (plist as NSDictionary).write(to: plistUrlNew, atomically: true)
//
//        do {
//            try validateIconState(old: plistUrl, new: plistUrlNew)
//            UIDevice.current.respring()
//        } catch {
//            do {
//                UIApplication.shared.alert(body: "New IconState appears to be invalid. Sorting has been aborted, and no system files have been edited. Specific error: \(error.localizedDescription). Please screenshot and report.")
//
//                let _ = try fm.replaceItemAt(plistUrl, withItemAt: plistUrlNew)
//            } catch {
//                UIApplication.shared.alert(body: error.localizedDescription)
//                return
//            }
//        }
    }
    
    static public func arePagesNeighbouring(pages: [Int]) -> Bool {
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
    /// Get the pages on the user's home screen, as well as any hidden pages
    public static func getPages() -> (Int, [Int]) {
        guard let plist = NSDictionary(contentsOf: plistUrl) as? [String:Any] else { return (0, []) }
        guard let iconLists = plist["iconLists"] as? [[Any]] else { return (0, []) }
        // Hidden pages
        var hiddenPages = [Int]()
        if let listMetadata = plist["listMetadata"] as? [String:[String:Any]] {
            guard let listUniqueIdentifiers = plist["listUniqueIdentifiers"] as? [String] else { return (0, []) }
            for (index, page) in listUniqueIdentifiers.enumerated() {
                for (key, value) in listMetadata {
                    if key == page && value.keys.contains("hiddenDate") {
                        hiddenPages.append(index + 1)
                    }
                }
            }
        }
        return (iconLists.count, hiddenPages)
    }

    
    private func validateIconState(old: URL, new: URL) throws {
        guard let oldState = NSDictionary(contentsOf: old) as? [String : NSObject] else { throw "Could not read \(old.lastPathComponent) in expected format" }
        guard let newState = NSDictionary(contentsOf: new) as? [String : NSObject] else { throw "Could not read \(new.lastPathComponent) in expected format" }
        
        // Make sure the file contains expected data
        guard newState.keys.contains("buttonBar") else { throw "Could not find key buttonBar in \(new.lastPathComponent)" }
        guard newState.keys.contains("iconLists") else { throw "Could not find key iconLists in \(new.lastPathComponent)" }
        
        for (key, value) in oldState {
            // Check that all keys are present in both
            if let value2 = newState[key] {
                if key == "iconLists" {
                    // Ensure all apps and folders are present in both
                    guard let iconListsOld = value as? [[NSObject]] else { throw "Could not read value of key \(key) in \(old.lastPathComponent) in expected format" }
                    guard let iconListsNew = newState[key] as? [[NSObject]] else { throw "Could not read value of key \(key) in \(new.lastPathComponent) in expected format" }
                    var iconSetOld: Set<NSObject> = []
                    var iconSetNew: Set<NSObject> = []
                    
                    for p in iconListsOld {
                        iconSetOld.formUnion(p)
                    }
                    for p in iconListsNew {
                        iconSetNew.formUnion(p)
                    }
                    if iconSetOld != iconSetNew { throw "Contents of iconLists array differs between \(old.lastPathComponent) and \(new.lastPathComponent)" }
                } else if key == "listMetadata" {
                    // listMetadata should be empty as we are showing all hidden pages
                    throw "Contents of listMetadata should be empty in \(new.lastPathComponent)"
                } else if key == "listUniqueIdentifiers" {
                    // Size of iconLists should equal size of listUniqueIdentifiers
                    guard let iconListsNew = newState["iconLists"] as? [[NSObject]] else { throw "Could not read value of key iconLists in \(new.lastPathComponent) in expected format" }
                    guard let listUniqueIdentifiers = newState["listUniqueIdentifiers"] as? [NSObject] else { throw "Could not read value of key listUniqueIdentifiers in \(new.lastPathComponent) in expected format" }
                    guard iconListsNew.count == listUniqueIdentifiers.count else { throw "Number of pages and page identifiers differs in \(new.lastPathComponent)" }
                } else if !value.isEqual(value2) {
                    throw "Value of key \(key) differs between \(old.lastPathComponent) and \(new.lastPathComponent)"
                }
            } else {
                guard key == "listMetadata" else { throw "Key \(key) missing from \(new.lastPathComponent)" }
            }
        }
        // Ensure no extraneous keys are present in the new file
        for (key, _) in newState {
            if oldState[key] == nil {
                throw "Additional key \(key) erroneously present in \(new.lastPathComponent)"
            }
        }
    }

}
