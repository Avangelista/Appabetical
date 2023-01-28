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
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.contains("iPad")
    }
    
    func checkAndEscape() {
#if targetEnvironment(simulator)
#else
        if #available(iOS 16.2, *) {
            UIApplication.shared.alert(title: "Not Supported", body: "This version of iOS is not supported.")
        } else {
            do {
                // TrollStore method
                try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "/var/mobile"), includingPropertiesForKeys: nil)
            } catch {
                // MDC method
                grant_full_disk_access() { error in
                    if error {
                        UIApplication.shared.alert(title: "Access Error", body: "Error: \(String(describing: error?.localizedDescription))\nPlease close the app and retry.")
                    }
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
