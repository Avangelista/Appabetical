//
//  AppabeticalApp.swift
//  Appabetical
//
//  Created by Rory Madden on 5/12/22.
//

import SwiftUI

@main
struct AppabeticalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            .onAppear {
                if (notAniPad()) {
                    checkNewVersions()
                }
            }
        }
    }
    
    func notAniPad() -> Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        if identifier.contains("iPad") {
            UIApplication.shared.alert(title: "Warning", body: "Appabetical does not support iPad! Please do not use the app as there may be unexpected side effects.")
            return false
        }
        return true
    }
    
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
