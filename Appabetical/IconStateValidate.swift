//
//  IconStateValidate.swift
//  Appabetical
//
//  Created by Rory Madden on 13/12/22.
//

import Foundation

func validateIconState(old: URL, new: URL) -> (Bool, String) {
    guard let oldState = NSDictionary(contentsOf: old) as? [String : NSObject] else { return (false, "Could not read \(old.lastPathComponent) in expected format") }
    guard let newState = NSDictionary(contentsOf: new) as? [String : NSObject] else { return (false, "Could not read \(new.lastPathComponent) in expected format") }
    
    guard newState.keys.contains("buttonBar") else { return (false, "Could not find key buttonBar in \(new.lastPathComponent)") }
    guard newState.keys.contains("iconLists") else { return (false, "Could not find key iconLists in \(new.lastPathComponent)") }
    
    for (key, value) in oldState {
        if let value2 = newState[key] {
            if key == "iconLists" {
                guard let iconListsOld = value as? [[NSObject]] else { return (false, "Could not read value of key \(key) in \(old.lastPathComponent) in expected format") }
                guard let iconListsNew = newState[key] as? [[NSObject]] else { return (false, "Could not read value of key \(key) in \(new.lastPathComponent) in expected format") }
                var iconSetOld: Set<NSObject> = []
                var iconSetNew: Set<NSObject> = []
                
                for p in iconListsOld {
                    iconSetOld.formUnion(p)
                }
                for p in iconListsNew {
                    iconSetNew.formUnion(p)
                }
                if iconSetOld != iconSetNew { return (false, "Contents of iconLists array differs between \(old.lastPathComponent) and \(new.lastPathComponent)") }
            } else if key == "listMetadata" {
                // listMetadata often contains date objects, which can have sub-second differences between saves
                // Check that the textual representations are equal to avoid sub-second differences
                if value.description != value2.description {
                    return (false, "Contents of listMetadata dictionary differs between \(old.lastPathComponent) and \(new.lastPathComponent)")
                }
            } else if !value.isEqual(value2) {
                return (false, "Value of key \(key) differs between \(old.lastPathComponent) and \(new.lastPathComponent)")
            }
        } else {
            return (false, "Key \(key) missing from \(new.lastPathComponent)")
        }
    }
    for (key, _) in newState {
        if oldState[key] == nil {
            return (false, "Additional key \(key) erroneously present in \(new.lastPathComponent)")
        }
    }
    return (true, "")
}
