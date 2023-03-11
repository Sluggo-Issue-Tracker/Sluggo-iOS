//
//  MultiSelectionList.swift
//  Sluggo-SwiftUI
//
//  Created by Troy Ebert on 3/9/23.
//

import Foundation
import SwiftUI

struct MultiSelectionList <Item: HasTitle & Identifiable & Hashable>: View {
    
    @Binding var items: [Item]
    @Binding var selected: [Item]
    
    var body: some View {
        Form {
            List() {
                ForEach(items, id: \.self) { item in
                    MultiSelectionRow(item: item, isSelected: selected.contains(item)) {
                        if selected.contains(item) {
                            selected = selected.filter(){ $0 != item }
                        }
                        else {
                            selected.append(item)
                        }
                    }
                }
            }
        }
    }
}

struct MultiSelectionRow <Item: HasTitle & Identifiable>: View {

    var item: Item
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(item.getTitle())
                    .foregroundColor(.black)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
