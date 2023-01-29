//
//  AppabeticalApp.swift
//  Appabetical
//
//  Created by Rory Madden on 5/12/22.
//

import SwiftUI
import Dynamic


typealias UsageReportCompletionBlock = @convention(block) (
    _ localUsageReports: NSArray?,
    _ usageReportsByDeviceIdentifier: NSDictionary?,
    _ aggregateUsageReports: NSArray?,
    _ error: NSError?) -> Void


@main
struct AppabeticalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            .onAppear {
                checkNewVersions()
                if isiPad() {
                    UIApplication.shared.alert(title: "Warning", body: "Appabetical does not support iPad yet! Please do not use the app as there may be unexpected side effects.")
                }
                checkAndEscape()
            }
//            .onAppear {
//                UsageTrackingWrapper.shared.getAppUsages(completion: { usages, error  in
//                    remLog("USAGES", usages)
//                })
//            }
        }
    }
    
    func isiPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func checkAndEscape() {
#if targetEnvironment(simulator)
#else
        var supported = false
        var needsTrollStore = false
        if #available(iOS 16.2, *) {
            supported = false
        } else if #available(iOS 16.0, *) {
            supported = true
            needsTrollStore = false
        } else if #available(iOS 15.7.2, *) {
            supported = false
        } else if #available(iOS 15.0, *) {
            supported = true
            needsTrollStore = false
        } else if #available(iOS 14.0, *) {
            supported = true
            needsTrollStore = true
        }
        
        if !supported {
            UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported. Please close the app.")
            return
        }
            
        do {
            // Check if application is entitled
            try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile"), includingPropertiesForKeys: nil)
        } catch {
            if needsTrollStore {
                UIApplication.shared.alert(title: "Use TrollStore", body: "You must install this app with TrollStore for it to work with this version of iOS. Please close the app.")
                return
            }
            // Use MacDirtyCOW to gain r/w
            grant_full_disk_access() { error in
                if (error != nil) {
                    UIApplication.shared.alert(body: "\(String(describing: error?.localizedDescription))\nPlease close the app and retry.")
                }
            }
        }
#endif
    }
    
    // Credit to SourceLocation
    // https://github.com/sourcelocation/AirTroller/blob/main/AirTroller/AirTrollerApp.swift
    func checkNewVersions() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/Avangelista/Appabetical/releases/latest") {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if (json["tag_name"] as? String)?.compare(version, options: .numeric) == .orderedDescending {
                        UIApplication.shared.confirmAlert(title: "Update Available", body: "A new version of Appabetical is available. It is recommended you update to avoid encountering bugs. Would you like to view the releases page?", onOK: {
                            UIApplication.shared.open(URL(string: "https://github.com/Avangelista/Appabetical/releases/latest")!)
                        }, noCancel: false)
                    }
                }
            }
            task.resume()
        }
    }
}
