//
//  AppUtils.swift
//  Appabetical
//
//  Created by Rory Madden on 12/12/22.
//

import Foundation
import AssetCatalogWrapper

class AppUtils {
    static let shared = AppUtils()
    private init() {
        fm = FileManager.default
        idToName = [:]
        idToIcon = [:]
        
        let apps = LSApplicationWorkspace.default().allApplications() ?? []
        for app in apps {
            // Get name
            let name = app.localizedName()
            idToName[app.applicationIdentifier] = name
            
            // Get icon
            let bundleUrl = app.bundleURL!
            let icon = _getIcon(bundleUrl: bundleUrl)
            idToIcon[app.applicationIdentifier] = icon
        }
    }

    private let fm: FileManager
    private var idToName: Dictionary<String, String>
    private var idToIcon: Dictionary<String, UIImage>
    
    private func _getIcon(bundleUrl: URL) -> UIImage {
        let infoPlistUrl = bundleUrl.appendingPathComponent("Info.plist")
        if !fm.fileExists(atPath: infoPlistUrl.path) {
            print("No Info.plist found")
            return UIImage()
        }
        let infoPlist = NSDictionary(contentsOf: infoPlistUrl) as! Dictionary<String, AnyObject>
        if infoPlist.keys.contains("CFBundleIcons") {
            let CFBundleIcons = infoPlist["CFBundleIcons"] as! Dictionary<String, AnyObject>
            if CFBundleIcons.keys.contains("CFBundlePrimaryIcon") {
                let CFBundlePrimaryIcon = CFBundleIcons["CFBundlePrimaryIcon"] as! Dictionary<String, AnyObject>
                if CFBundlePrimaryIcon.keys.contains("CFBundleIconName") {
                    // Check assets file, hope there's a better way than this
                    let CFBundleIconName = CFBundlePrimaryIcon["CFBundleIconName"] as! String
                    let assetsUrl = bundleUrl.appendingPathComponent("Assets.car")
                    do {
                        let (_, renditionsRoot) = try AssetCatalogWrapper.shared.renditions(forCarArchive: assetsUrl)
                        for rendition in renditionsRoot {
                            let renditions = rendition.renditions
                            for rend in renditions {
                                if rend.namedLookup.name == CFBundleIconName {
                                    return UIImage(cgImage: rend.image!)
                                }
                            }
                        }
                    } catch {
                        print("Error with assets.car")
                        // fall thru
                    }
                }
                if CFBundlePrimaryIcon.keys.contains("CFBundleIconFiles") {
                    // Check bundle file
                    let CFBundleIconFiles = CFBundlePrimaryIcon["CFBundleIconFiles"] as! Array<String>
                    if !CFBundleIconFiles.isEmpty {
                        let iconName = CFBundleIconFiles[0]
                        let appIcon = _iconFromFile(iconName: iconName, bundleUrl: bundleUrl)
                        return appIcon
                    }
                }
            }
        }
        if infoPlist.keys.contains("CFBundleIconFiles") {
            // Check bundle file
            let CFBundleIconFiles = infoPlist["CFBundleIconFiles"] as! Array<String>
            if !CFBundleIconFiles.isEmpty {
                let iconName = CFBundleIconFiles[0]
                let appIcon = _iconFromFile(iconName: iconName, bundleUrl: bundleUrl)
                return appIcon
            }
        }
        
        // Nothing found
        print("No icons found for app")
        return UIImage()
    }
    
    // Get an app's icon from its bundle file
    private func _iconFromFile(iconName: String, bundleUrl: URL) -> UIImage {
        var iconFile = ""
        var iconFound = false
        if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + ".png").path) {
            iconFile = iconName + ".png"
            iconFound = true
        } else if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + "@2x.png").path) {
            iconFile = iconName + "@2x.png"
            iconFound = true
        } else if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + "-large.png").path) {
            iconFile = iconName + "-large.png"
            iconFound = true
        } else if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + "@23.png").path) {
            iconFile = iconName + "@23.png"
            iconFound = true
        } else if fm.fileExists(atPath: bundleUrl.appendingPathComponent(iconName + "@3x.png").path) {
            iconFile = iconName + "@3x.png"
            iconFound = true
        }

        if iconFound {
            let iconUrl = (bundleUrl.appendingPathComponent(iconFile))
            do {
                let iconData = try Data(contentsOf: iconUrl)
                let icon = UIImage(data: iconData)!
                return icon
            } catch {
                print(error.localizedDescription)
                return UIImage()
            }
        }
        
        print("No icon found in bundle file")
        return UIImage()
    }
    
    func getIcon(id: String) -> UIImage {
        return idToIcon[id]!
    }
    
    func getName(id: String) -> String {
        return idToName[id]!
    }
}

