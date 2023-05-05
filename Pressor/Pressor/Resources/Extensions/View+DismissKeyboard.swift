//
//  View+DismissKeyboard.swift
//  Pressor
//
//  Created by Celan on 2023/05/05.
//

import SwiftUI

extension View {
    func hideKeyboard() {
           UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
           )
       }
}
