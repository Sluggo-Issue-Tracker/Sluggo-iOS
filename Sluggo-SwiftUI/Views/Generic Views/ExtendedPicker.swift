//
//  ExtendedPicker.swift
//  Sluggo-SwiftUI
//
//  Created by Troy Ebert on 3/10/23.
//

import Foundation
import SwiftUI

struct ExtendedPicker<Item: HasTitle & Identifiable & Hashable>: View {
    
    var title: String
    @Binding var items: [Item]
    @Binding var selected: Item?
    
    var body: some View {
        NavigationLink() {
            PickerDetail(items: $items, selected: $selected)
                .navigationBarTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        } label: {
            HStack{
                Text(title)
                    .frame(alignment: .leading)
                Spacer()
                Text("\(selected?.getTitle() ?? "None")")
                    .frame(alignment: .trailing)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct PickerDetail <Item: HasTitle & Identifiable & Hashable>: View {
    
    @Binding var items: [Item]
    @Binding var selected: Item?
    
    var body: some View {
        Form {
            Picker("Picker", selection: $selected) {
                Text("None").tag(nil as Item?)
                ForEach(items, id: \.self) { item in
                    Text(item.getTitle()).tag(item as Item?)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }
}

