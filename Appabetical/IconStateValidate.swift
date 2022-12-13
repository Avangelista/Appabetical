//
//  IconStateValidate.swift
//  Appabetical
//
//  Created by Rory Madden on 13/12/22.
//

import Foundation

func validateIconState(old: URL, new: URL) -> Bool {
    guard let oldState = NSDictionary(contentsOf: old) as? [String : NSObject] else { return false }
    guard let newState = NSDictionary(contentsOf: new) as? [String : NSObject] else { return false }
    
    guard !newState.keys.contains("buttonBar") else { return false }
    guard !newState.keys.contains("iconLists") else { return false }
    
    for (key, value) in oldState {
        if let value2 = newState[key] {
            if key == "iconLists" {
                guard let iconListsOld = value as? [[NSObject]] else { return false }
                guard let iconListsNew = newState[key] as? [[NSObject]] else { return false }
                var iconSetOld: Set<NSObject> = []
                var iconSetNew: Set<NSObject> = []
                
                for p in iconListsOld {
                    iconSetOld.formUnion(p)
                }
                for p in iconListsNew {
                    iconSetNew.formUnion(p)
                }
                if iconSetOld != iconSetNew { return false }
            } else if !value.isEqual(value2) {
                return false
            }
        } else {
            return false
        }
    }
    for (key, _) in newState {
        if oldState[key] == nil {
            return false
        }
    }
    return true
}

//import Foundation
//
//func validateIconState(old: URL, new: URL) -> Bool {
//    let oldState = NSDictionary(contentsOf: old) as? Dictionary<String, NSObject>
//    let newState = NSDictionary(contentsOf: new) as? Dictionary<String, NSObject>
//
//    if oldState == nil || newState == nil { return false }
//
//    if !newState!.keys.contains("buttonBar") { return false }
//    if !newState!.keys.contains("iconLists") { return false }
//
//    for (key, value) in oldState! {
//        if let value2 = newState?[key] {
//            if key == "iconLists" {
//                let iconListsOld = value as! Array<Array<NSObject>>
//                let iconListsNew = newState?[key] as! Array<Array<NSObject>>
//                var iconSetOld = Set<NSObject>()
//                var iconSetNew = Set<NSObject>()
//
//                for p in iconListsOld {
//                    iconSetOld.formUnion(p)
//                }
//                for p in iconListsNew {
//                    iconSetNew.formUnion(p)
//                }
//                if iconSetOld != iconSetNew { return false }
//            } else if !value.isEqual(value2) {
//                return false
//            }
//        } else {
//            return false
//        }
//    }
//    for (key, _) in newState! {
//        if oldState?[key] == nil {
//            return false
//        }
//    }
//    return true
//}
