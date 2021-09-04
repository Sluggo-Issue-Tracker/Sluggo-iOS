//
//  LoginTextField.swift
//  LoginTextField
//
//  Created by Andrew Gavgavian on 9/3/21.
//

import SwiftUI

struct LoginTextField: View {
    @State var placeholder: String
    @Binding var textValue: String
    @State var textStyle: UITextContentType
    var isSecure: Bool = false
    var body: some View {
        if isSecure == true {
            SecureField(placeholder, text: $textValue)
                .textContentType(textStyle)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        } else {
            TextField(placeholder, text: $textValue)
                .textContentType(textStyle)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        
    }
}

struct LoginTextField_Previews: PreviewProvider {
    static var previews: some View {
        LoginTextField(placeholder: "Placeholder", textValue: .constant(""), textStyle: .username)
    }
}
