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

/*
struct ExtendedPicker<Item: HasTitle & Identifiable & Hashable>: View {
    
    var title: String
    @Binding var items: [Item]
    @Binding var selected: Item?
    
    var body: some View {
        HStack() {
            Text(title)
            Spacer()
            Menu {
                Picker("Picker", selection: $selected) {
                    Text("None").tag(nil as Item?)
                    ForEach(items, id: \.self) { item in
                        Text(item.getTitle()).tag(item as Item?)
                    }
                    
                }
                .labelsHidden()
                Divider()
                NavigationLink() {
                    PickerDetail(items: $items, selected: $selected)
                } label: {
                    Text("More")
                }
            } label: {
                HStack(spacing: 3) {
                    Text("\(selected?.getTitle() ?? "None")")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 15))
                        .frame(alignment: .center)
                }
                .fixedSize()
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .foregroundColor(.gray)
            .frame(alignment: .trailing)
            .transaction { transaction in
                transaction.animation = nil
            }
        }
    }
}
*/
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

