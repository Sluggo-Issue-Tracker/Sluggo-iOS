//
//  CheckBox.swift
//  CheckBox
//
//  Created by Andrew Gavgavian on 9/3/21.
//

import SwiftUI

struct CheckBox: View {
    @Binding var checked: Bool
    var caption: String
    
    var body: some View {
        HStack {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
                .onTapGesture {
                    self.checked.toggle()
                }
            
            Text(caption)
                .font(.caption)
                .fontWeight(.regular)
        }
    }
}

struct CheckBox_Previews: PreviewProvider {
    static var previews: some View {
        CheckBox(checked: .constant(true), caption: "A default caption")
    }
}
