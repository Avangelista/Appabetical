//
//  MultiSelectPickerView.swift
//  Appabetical
//
//  Created by Rory Madden on 13/12/22.
//

import Foundation
import SwiftUI

// Custom multi-select picker
// https://www.simplykyra.com/2022/02/23/how-to-make-a-custom-picker-with-multi-selection-in-swiftui/
struct MultiSelectPickerView: View {
    @State var allItems: [Int]
    @Binding var selectedItems: [Int]
    @Binding var pageOp: PageOptions
 
    var body: some View {
        Form {
            List {
                Section(header: Text("Pages")) {
                    ForEach(allItems, id: \.self) { item in
                        Button(action: {
                            withAnimation {
                                if self.selectedItems.contains(item) {
                                    self.selectedItems.removeAll(where: { $0 == item })
                                } else {
                                    self.selectedItems.append(item)
                                }
                                self.selectedItems.sort()
                                if !areNeighbouring(pages: self.selectedItems) {
                                    self.pageOp = PageOptions.individually // bug here
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                    .opacity(self.selectedItems.contains(item) ? 1.0 : 0.0)
                                Text("Page \(String(item))")
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
