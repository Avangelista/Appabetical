//
//  SpringBoardItem.swift
//  Appabetical
//
//  Created by exerhythm on 17.12.2022.
//

import Foundation


class SpringBoardItem {
    func compare(to item2: SpringBoardItem, folderSortingOption: SortingManager.FolderSortingOption, sortingOption: SortingManager.SortOption) -> Bool {
        let item1 = self
        
        if item1.type == .widget || item2.type == .widget {
            if item1.type == .widget, item2.type == .widget {
                return item1.widgetSize?.rawValue ?? 0 > item2.widgetSize?.rawValue ?? 0
            } else if item1.type == .widget {
                return true
            } else if item2.type == .widget {
                return false
            }
        } else if item1.type == .folder || item2.type == .folder {
            if item1.type == .folder, item2.type == .folder {
                return folderSortingOption == .noSort ? false : (item1.title.lowercased() < item2.title.lowercased())
            } else if item1.type == .folder {
                return true
            } else if item2.type == .folder {
                return false
            }
        }
        if sortingOption == .color {
            if item1.type == .app, item2.type == .app {
               var hue1: CGFloat = 0
               var saturation1: CGFloat = 0
               var brightness1: CGFloat = 0
               var alpha1: CGFloat = 0
                SpringBoardAppUtils.shared.getColor(id: item1.bundleID).getHue(&hue1, saturation: &saturation1, brightness: &brightness1, alpha: &alpha1)

               var hue2: CGFloat = 0
               var saturation2: CGFloat = 0
               var brightness2: CGFloat = 0
               var alpha2: CGFloat = 0
                SpringBoardAppUtils.shared.getColor(id: item2.bundleID).getHue(&hue2, saturation: &saturation2, brightness: &brightness2, alpha: &alpha2)

               if hue1 < hue2 {
                   return true
               } else if hue1 > hue2 {
                   return false
               }

               if saturation1 < saturation2 {
                   return true
               } else if saturation1 > saturation2 {
                   return false
               }

               if brightness1 < brightness2 {
                   return true
               } else if brightness1 > brightness2 {
                   return false
               }
           }
        }
        return item1.title.lowercased() < item2.title.lowercased()
    }
    
    var title: String
    var bundleID: String
    var widgetSize: ItemSize?
    var type: ItemType
    
    init(title: String,  bundleID: String, widgetSize: ItemSize? = nil, type: ItemType) {
        self.title = title
        self.bundleID = bundleID
        self.widgetSize = widgetSize
        self.type = type
    }
    
    
}