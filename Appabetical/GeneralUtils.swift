////
////  GeneralUtils.swift
////  Appabetical
////
////  Created by Rory Madden on 14/12/22.
////
//
//import Foundation
//
//func getItemSize(item: [String:Any]) -> ItemSize {
//    if let iconType = item["iconType"] as? String  {
//        if iconType == "custom" {
//            if let gridSize = item["gridSize"] as? String  {
//                switch gridSize {
//                case "small": return .small
//                case "medium": return .medium
//                case "large": return .large
//                default: return .unknown
//                }
//            }
//        }
//    }
//    return .normal
//}
//
//func getSpringBoardItem(item: Any) throws -> SpringBoardItem {
//    if let item = item as? String {
//        // App / web clip / app clip
//        return .init(title: item, bundleID: item, type: .app)
//    } else if let item = item as? [String : Any] {
//        if let iconType = item["iconType"] as? String {
//            // Duplicate app
//            if iconType == "app" {
//                if let bundleIdentifier = item["bundleIdentifier"] as? String {
//                    return .init(title: SpringBoardAppUtils.shared.getName(id: bundleIdentifier), bundleID: bundleIdentifier, type: .app)
//                }
//            // Widget
//            } else if iconType == "custom" {
//                return .init(title: "", bundleID: "", widgetSize: getItemSize(item: item), type: .widget)
//            }
//        } else if let listType = item["listType"] as? String {
//            // Folder
//            if listType == "folder" {
//                if let displayName = item["displayName"] as? String {
//                    return .init(title: displayName, bundleID: "", type: .folder)
//                }
//            }
//        }
//    }
//    throw "Unknown app type"
//}
//
//// Check if all selected pages are neighbouring
//func arePagesNeighbouring(pages: [Int]) -> Bool {
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
//
//
