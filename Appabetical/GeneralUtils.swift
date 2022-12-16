//
//  GeneralUtils.swift
//  Appabetical
//
//  Created by Rory Madden on 14/12/22.
//

import Foundation

func getItemSize(item: Any) -> ItemSize {
    if item is [String:AnyObject] {
        guard let dict = item as? [String:AnyObject] else { return .unknown }
        if dict.keys.contains("iconType") {
            guard let iconType = dict["iconType"] as? String else { return .unknown }
            if iconType == "custom" {
                if dict.keys.contains("gridSize") {
                    guard let gridSize = dict["gridSize"] as? String else { return .unknown }
                    switch gridSize {
                    case "small": return .small
                    case "medium": return .medium
                    case "large": return .large
                    default: return .unknown
                    }
                }
            }
        }
    }
    return .normal
}

func getTypeBundleName(item: Any) -> (ItemType, String, String) {
    if item is String{
        // App / web clip / app clip
        guard let itemS = item as? String else { return (.unknown, "", "") }
        return (.app, itemS, AppUtils.shared.getName(id: itemS))
    } else if item is [String:AnyObject] {
        guard let dict = item as? [String:AnyObject] else { return (.unknown, "", "") }
        if dict.keys.contains("iconType") {
            guard let iconType = dict["iconType"] as? String else { return (.unknown, "", "") }
            // Duplicate app
            if iconType == "app" {
                if dict.keys.contains("bundleIdentifier") {
                    guard let bundleIdentifier = dict["bundleIdentifier"] as? String else { return (.unknown, "", "") }
                    return (.app, bundleIdentifier, AppUtils.shared.getName(id: bundleIdentifier))
                }
            // Widget
            } else if iconType == "custom" {
                return (.widget, "", "")
            }
        } else if dict.keys.contains("listType") {
            guard let listType = dict["listType"] as? String else { return (.unknown, "", "") }
            // Folder
            if listType == "folder" {
                if dict.keys.contains("displayName") {
                    guard let displayName = dict["displayName"] as? String else { return (.unknown, "", "") }
                    return (.folder, "", displayName)
                }
            }
        }
    }
    return (.unknown, "", "")
}

// Check if all selected pages are neighbouring
func areNeighbouring(pages: [Int]) -> Bool {
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

// Respring the device if enabled
func respring() {
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        guard let window = UIApplication.shared.windows.first else { return }
        while true {
            window.snapshotView(afterScreenUpdates: false)
        }
    }
}

// Get the time saved of a file in yyyy-MM-dd HH:mm
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
            return "(unknown)"
        }
    }
    return "(unknown)"
}

// Get the number of pages on the user's home screen TODO check when sorting too
func getPages() -> (Int, [Int]) {
    guard let plist = NSDictionary(contentsOf: plistUrl) as? [String:AnyObject] else { return (0, []) }
    guard let iconLists = plist["iconLists"] as? [[AnyObject]] else { return (0, []) }
    // Hidden pages
    var hiddenPages = [Int]()
    if let listMetadata = plist["listMetadata"] as? [String:[String:AnyObject]] {
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
