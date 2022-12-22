//
//  ContentView.swift
//  Appabetical
//
//  Created by Rory Madden on 5/12/22.
//

import SwiftUI
import MobileCoreServices

struct ContentView: View {
    
    // Settings variables
    @State private var selectedItems = [Int]()
    @State private var pageOp = IconStateManager.PageSortingOption.individually
    @State private var folderOp = IconStateManager.FolderSortingOption.noSort
    @State private var sortOp = IconStateManager.SortOption.alphabetically
    @State private var widgetOp = WidgetOptions.top
    
    @Environment(\.openURL) var openURL
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: {
                        MultiSelectPickerView(pages: IconStateManager.getPages(), selectedItems: $selectedItems, pageOp: $pageOp).navigationBarTitle("", displayMode: .inline)
                    }, label: {
                        HStack {
                            Text("Select Pages")
                            Spacer()
                            Text(selectedItems.map { String($0 + 1) }.joined(separator: ", ")).foregroundColor(.secondary)
                        }
                    })
                    Picker("Ordering", selection: $sortOp) {
                        Text("A-Z").tag(IconStateManager.SortOption.alphabetically)
                        Text("Color").tag(IconStateManager.SortOption.color)
                    }.onChange(of: sortOp, perform: {nv in if nv == .color && folderOp == .alongside { folderOp = .separately }})
                    Picker("Pages", selection: $pageOp) {
                        Text("Sort pages independently").tag(IconStateManager.PageSortingOption.individually)
                        Text("Sort apps across pages").tag(IconStateManager.PageSortingOption.acrossPages)
                    }
                    Picker("Folders", selection: $folderOp) {
                        Text("Retain current order").tag(IconStateManager.FolderSortingOption.noSort)
                        if (sortOp == .alphabetically) {
                            Text("Sort mixed with apps").tag(IconStateManager.FolderSortingOption.alongside)
                        }
                        Text("Sort separate from apps").tag(IconStateManager.FolderSortingOption.separately)
                    }
                    Picker("Widgets", selection: $widgetOp) {
                        Text("Move to top").tag(WidgetOptions.top)
                    }
                    Button("Sort Apps") {
                        sortPage()
                    }.disabled(selectedItems.isEmpty)
                }
                Section (footer: fm.fileExists(atPath: savedLayoutUrl.path) ? Text("The previously saved layout will be overwritten.") : Text("It is recommended you save your current layout before experimenting as only one undo is possible.")) {
                    Button("Undo Last Sort") {
                        restoreBackup()
                    }.disabled(!fm.fileExists(atPath: plistUrlBkp.path))
                    Button("Restore Saved Layout") {
                        restoreLayout()
                    }.disabled(!fm.fileExists(atPath: savedLayoutUrl.path))
                    Button("Back Up Current Layout") {
                        saveLayout()
                    }
                }
            }.navigationTitle("Appabetical")
                .toolbar {
                    // Credit to SourceLocation
                    // https://github.com/sourcelocation/AirTroller/blob/main/AirTroller/ContentView.swift
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            openURL(URL(string: "https://github.com/Avangelista/Appabetical")!)
                        }) {
                            Image("github")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                        }
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            openURL(URL(string: "https://ko-fi.com/avangelista")!)
                        }) {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                        }
                    }
                    
                }
        }
    }
    
    
    // Sort the selected pages
    func sortPage() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        do {
            let pageCount = try IconStateManager.shared.pageCount()
            selectedItems = selectedItems.filter {$0 - 1 < pageCount }
            if selectedItems.isEmpty { return }
            
            try IconStateManager.shared.sortPages(selectedPages: selectedItems, sortOption: sortOp, pageSortingOption: pageOp, folderSortingOption: folderOp)
            UIDevice.current.respring()
        } catch {  UIApplication.shared.alert(body: error.localizedDescription) }
    }
    
    func saveLayout() {
        BackupManager.saveLayout()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func restoreBackup() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIApplication.shared.confirmAlert(title: "Confirm Undo", body: "This layout was saved on \(BackupManager.getTimeSaved(url: plistUrlBkp) ?? "(unknown date)"). Be mindful if you've added any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
            do {
                try BackupManager.restoreBackup()
                UIDevice.current.respring()
            } catch {  UIApplication.shared.alert(body: error.localizedDescription) }
        })
    }
    
    func restoreLayout() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIApplication.shared.confirmAlert(title: "Confirm Restore", body: "This layout was saved on \(BackupManager.getTimeSaved(url: savedLayoutUrl) ?? "(unknown date)"). Be mindful if you've added/removed any apps, widgets or folders since then as they may appear incorrectly. Would you like to continue?", onOK: {
            do {
                try BackupManager.restoreLayout()
                UIDevice.current.respring()
            } catch {  UIApplication.shared.alert(body: error.localizedDescription) }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
