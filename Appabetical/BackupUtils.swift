//
//  BackupUtils.swift
//  Appabetical
//
//  Created by Rory Madden on 14/12/22.
//

import Foundation

// Save a homescreen backup manually
func saveLayout() {
    do {
        if fm.fileExists(atPath: savedLayoutUrl.path) {
            try fm.removeItem(at: savedLayoutUrl)
        }
        try fm.copyItem(at: plistUrl, to: savedLayoutUrl)
        // Set modification date to now
        let attributes: [FileAttributeKey : Any] = [.modificationDate: Date()]
        try fm.setAttributes(attributes, ofItemAtPath: savedLayoutUrl.path)
        UIApplication.shared.alert(title: "Layout Saved", body: "Layout has been saved successfully.")
    } catch {
        UIApplication.shared.alert(body: error.localizedDescription)
    }
}

// Restore the manual homescreen backup
func restoreLayout() {
    UIApplication.shared.confirmAlert(title: "Confirm Restore", body: "This layout was saved on \(getTimeSaved(url: savedLayoutUrl)). Be mindful if you've added any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
        do {
            try fm.replaceItemAt(plistUrl, withItemAt: savedLayoutUrl)
            try fm.copyItem(at: plistUrl, to: savedLayoutUrl)
            if fm.fileExists(atPath: plistUrlBkp.path) {
                try fm.removeItem(at: plistUrlBkp)
            }
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
            return
        }

        respring()
    }, noCancel: false)
}

// Make a backup
func makeBackup() {
    do {
        if fm.fileExists(atPath: plistUrlBkp.path) {
            try fm.removeItem(at: plistUrlBkp)
        }
        try fm.copyItem(at: plistUrl, to: plistUrlBkp)
        // Set modification date to now
        let attributes: [FileAttributeKey : Any] = [.modificationDate: Date()]
        try fm.setAttributes(attributes, ofItemAtPath: plistUrlBkp.path)
    } catch {
        UIApplication.shared.alert(body: error.localizedDescription)
        return
    }
}

// Restore the latest backup
func restoreBackup() {
    UIApplication.shared.confirmAlert(title: "Confirm Undo", body: "This layout was saved on \(getTimeSaved(url: plistUrlBkp)). Be mindful if you've added/removed any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
        do {
            try fm.replaceItemAt(plistUrl, withItemAt: plistUrlBkp)
        } catch {
            UIApplication.shared.alert(body: error.localizedDescription)
            return
        }

        respring()
    }, noCancel: false)
}
