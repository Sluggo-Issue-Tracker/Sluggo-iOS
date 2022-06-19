//
//  SingleSelectionList.swift
//  Sluggo-SwiftUI
//
//  Created by Andrew Gavgavian on 6/16/22.
//

import Foundation
import SwiftUI


struct SingleSelectionList<Item: Identifiable & HasTitle & Equatable, Content: View>: View {
    
    var items: [Item]
    @Binding var didChange: Bool
    @Binding var selection: Item?
    var rowContent: (Item) -> Content
    
    var body: some View {
        ForEach(items, id: \.id) { item in
            rowContent(item)
                .modifier(CheckmarkModifier(checked: self.isChecked(item: item)))
                .contentShape(Rectangle())
                .onTapGesture {
                    if self.selection != item {
                        self.selection = item
                    } else {
                        self.selection = nil
                    }
                    didChange = true
                }
        }
    }
    private func isChecked(item: Item) -> Bool {
        
        return self.selection?.getTitle() == item.getTitle()
    }
}



struct CheckmarkModifier: ViewModifier {
    var checked: Bool = false
    func body(content: Content) -> some View {
        Group {
            if checked {
                ZStack(alignment: .trailing) {
                    content
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            } else {
                content
            }
        }
    }
}
