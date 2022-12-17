//
//  IconStateValidate.swift
//  Appabetical
//
//  Created by Rory Madden on 13/12/22.
//

import Foundation


func validateIconState(old: URL, new: URL) throws {
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
