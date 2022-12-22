//
//  MultiSelectPickerView.swift
//  Appabetical
//
//  Credit to SimplyKyra
//  https://github.com/SimplyKyra/SimplyKyraBlog/blob/main/SwiftExamples/CustomMultiSelectionPicker.swift
//

import Foundation
import SwiftUI

// Custom multi-select picker
struct MultiSelectPickerView: View {
    @State var pages: (Int, [Int])
    @Binding var selectedItems: [Int]
    @Binding var pageOp: IconStateManager.PageSortingOption
 
    var body: some View {
        Form {
            List {
                let (numPages, hiddenPages) = pages
                Section(header: Text("Pages"), footer: hiddenPages.isEmpty ? Text("") : Text("All hidden pages will be unhidden.")) {
                    ForEach(0...numPages - 1, id: \.self) { item in
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            
                            if self.selectedItems.contains(item) {
                                self.selectedItems.removeAll(where: { $0 == item })
                            } else {
                                self.selectedItems.append(item)
                            }
                            self.selectedItems.sort()
                            if !IconStateManager.arePagesNeighbouring(pages: self.selectedItems) {
                                self.pageOp = IconStateManager.PageSortingOption.individually // bug here
                            }
                        }) {
                            HStack {
                                Text("Page \(String(item + 1))\(hiddenPages.contains(item) ? " (hidden)" : "")")
                                Spacer()
                                Image(systemName: "checkmark")
                                    .opacity(self.selectedItems.contains(item) ? 1.0 : 0.0)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                Section(header: Text("Folders")) {
                    Text("Coming Soon").foregroundColor(.secondary)
                }
            }
        }
    }
}
