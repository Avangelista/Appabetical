//
//  ComparatorUtils.swift
//  Appabetical
//
//  Created by Rory Madden on 13/12/22.
//

import Foundation
import SwiftUI

func compareByTypeColor(object1: Any, object2: Any, colorArray: Dictionary<String, UIColor>) -> Bool {
    // add for web clip thing
    if object1 is String && object2 is String {
        var hue1: CGFloat = 0
        var saturation1: CGFloat = 0
        var brightness1: CGFloat = 0
        var alpha1: CGFloat = 0
        colorArray[object1 as! String]!.getHue(&hue1, saturation: &saturation1, brightness: &brightness1, alpha: &alpha1)

        var hue2: CGFloat = 0
        var saturation2: CGFloat = 0
        var brightness2: CGFloat = 0
        var alpha2: CGFloat = 0
        colorArray[object2 as! String]!.getHue(&hue2, saturation: &saturation2, brightness: &brightness2, alpha: &alpha2)

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
    } else if object1 is String {
        return false
    } else if object2 is String {
        return true
    }
    // add a case here for folders at top
    return true
}

// Needless complex but we get it
func compareByType(object1: Any, object2: Any, folderOp: FolderOptions) -> Bool {
    var o1New = ""
    var o2New = ""
    var o1Folder = false
    var o2Folder = false
    
    if object1 is String{
        o1New = AppUtils.shared.getName(id: object1 as! String)
    } else if object1 is Dictionary<String, AnyObject> {
        let dict = object1 as! Dictionary<String, AnyObject>
        if dict.keys.contains("iconType") {
            let iconType = dict["iconType"] as! String
            // It's an app
            if iconType == "app" {
                if dict.keys.contains("bundleIdentifier") {
                    let bundleIdentifier = dict["bundleIdentifier"] as! String
                    o1New = AppUtils.shared.getName(id: bundleIdentifier)
                }
            // It's a widget
            } else if iconType == "custom" {
                return true // send it to the top
            } else {
                return true // idk
            }
        } else if dict.keys.contains("listType") {
            let listType = dict["listType"] as! String
            // It's a folder
            if listType == "folder" {
                o1Folder = true
                if folderOp == FolderOptions.noSort {
                    return false // i think
                } else if folderOp == FolderOptions.alongside {
                    if dict.keys.contains("displayName") {
                        let displayName = dict["displayName"] as! String
                        o1New = displayName
                    }
                } else if folderOp == FolderOptions.separately {
                    if dict.keys.contains("displayName") {
                        let displayName = dict["displayName"] as! String
                        o1New = displayName
                    }
                }
            } else {
                return true // idk
            }
        } else {
            return true // idk
        }
    } else {
        return true // idk
    }
    
    if object2 is String{
        o2New = AppUtils.shared.getName(id: object2 as! String)
    } else if object2 is Dictionary<String, AnyObject> {
        let dict = object2 as! Dictionary<String, AnyObject>
        if dict.keys.contains("iconType") {
            let iconType = dict["iconType"] as! String
            // It's an app
            if iconType == "app" {
                if dict.keys.contains("bundleIdentifier") {
                    let bundleIdentifier = dict["bundleIdentifier"] as! String
                    o2New = AppUtils.shared.getName(id: bundleIdentifier)
                }
            // It's a widget
            } else if iconType == "custom" {
                return false // send it to the top
            } else {
                return true // idk
            }
        } else if dict.keys.contains("listType") {
            let listType = dict["listType"] as! String
            // It's a folder
            if listType == "folder" {
                o2Folder = true
                if folderOp == FolderOptions.noSort {
                    return true // i think
                } else if folderOp == FolderOptions.alongside {
                    if dict.keys.contains("displayName") {
                        let displayName = dict["displayName"] as! String
                        o2New = displayName
                    }
                } else if folderOp == FolderOptions.separately {
                    if dict.keys.contains("displayName") {
                        let displayName = dict["displayName"] as! String
                        o2New = displayName
                    }
                }
            } else {
                return true // idk
            }
        } else {
            return true // idk
        }
    } else {
        return true // idk
    }
    
    if folderOp == FolderOptions.separately {
        if o1Folder && o2Folder {
            return o1New.lowercased() < o2New.lowercased()
        } else if o1Folder {
            return true
        } else if o2Folder {
            return false
        }
    }
    return o1New.lowercased() < o2New.lowercased()
}
