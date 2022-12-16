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
                // listMetadata should be empty as we are showing all hidden pages
                return (false, "Contents of listMetadata should be empty in \(new.lastPathComponent)")
            } else if key == "listUniqueIdentifiers" {
                // Size of iconLists should equal size of listUniqueIdentifiers
                guard let iconListsNew = newState["iconLists"] as? [[NSObject]] else { return (false, "Could not read value of key iconLists in \(new.lastPathComponent) in expected format") }
                guard let listUniqueIdentifiers = newState["listUniqueIdentifiers"] as? [NSObject] else { return (false, "Could not read value of key listUniqueIdentifiers in \(new.lastPathComponent) in expected format") }
                guard iconListsNew.count == listUniqueIdentifiers.count else { return (false, "Number of pages and page identifiers differs in \(new.lastPathComponent)") }
            } else if !value.isEqual(value2) {
                return (false, "Value of key \(key) differs between \(old.lastPathComponent) and \(new.lastPathComponent)")
            }
        } else {
            guard key == "listMetadata" else { return (false, "Key \(key) missing from \(new.lastPathComponent)") }
        }
    }
    for (key, _) in newState {
        if oldState[key] == nil {
            return (false, "Additional key \(key) erroneously present in \(new.lastPathComponent)")
        }
    }
    return (true, "")
}
