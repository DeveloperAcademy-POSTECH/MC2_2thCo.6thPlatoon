//
//  ToggleStyle.swift
//  Pressor
//
//  Created by Celan on 2023/05/18.
//

import SwiftUI

struct CircleToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Circle()
                .stroke(Color.pressorSystemGray_dark, lineWidth: 2)
                .background(
                    configuration.isOn
                    ? Color.green
                    : Color.clear
                )
                .clipShape(Circle())
                .frame(width: 25, height: 25)
                .overlay {
                    Image(systemName: configuration.isOn ? "checkmark" : "")
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
            configuration.label
        }
    }
}
