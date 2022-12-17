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
    @Binding var pageOp: PageSortingOption
 
    var body: some View {
        Form {
            List {
                let (numPages, hiddenPages) = pages
                Section(header: Text("Pages"), footer: hiddenPages.isEmpty ? Text("") : Text("All hidden pages will be unhidden.")) {
                    ForEach(1...numPages, id: \.self) { item in
                        Button(action: {
                            withAnimation {
                                if self.selectedItems.contains(item) {
                                    self.selectedItems.removeAll(where: { $0 == item })
                                } else {
                                    self.selectedItems.append(item)
                                }
                                self.selectedItems.sort()
                                if !areNeighbouring(pages: self.selectedItems) {
                                    self.pageOp = PageSortingOption.individually // bug here
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                    .opacity(self.selectedItems.contains(item) ? 1.0 : 0.0)
                                if hiddenPages.contains(item) {
                                    Text("Page \(String(item)) (hidden)")
                                } else {
                                    Text("Page \(String(item))")
                                }
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
