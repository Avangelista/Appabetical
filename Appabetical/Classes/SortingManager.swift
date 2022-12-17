//
//  SortingManager.swift
//  Appabetical
//
//  Created by exerhythm on 17.12.2022.
//

import Foundation

public class SortingManager {
    
    static var shared = SortingManager()
    
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
                                         [try iconLists.reduce([], +).map { try getSpringBoardItem(item: $0) }] :
                                            try iconLists.map { try $0.map { try getSpringBoardItem(item: $0) } }
        )
        
        // Sort each selected page
        springBoardItemsFlattened = springBoardItemsFlattened.map {
            $0.sorted { item1, item2 in
                item1.compare(to: item2, folderSortingOption: folderSortingOption, sortingOption: sortOption)
            }
        }
        
        // Evenly distribute icons amongst pages to avoid overflow
        var pageCount: Int
        if pageSortingOption == .acrossPages {
            var newNewIconLists = [[AnyObject]]() // great variable naming!!!!!
            for page in springBoardItemsFlattened {
                var pageSize = 0
                var pageNew = [AnyObject]()
                for item in page {
                    let itemSize = item.widgetSize?.rawValue ?? 0
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
}
