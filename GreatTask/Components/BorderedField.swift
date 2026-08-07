//
//  BorderedField.swift
//  GreatTask
//
//  Created by Danylo Litvinchuk on 07.08.2026.
//

import SwiftUI

struct BorderedFieldModifier: ViewModifier {

    private enum Constants {
        static let height: CGFloat = 30
        static let cornerRadius: CGFloat = 6
        static let borderWidth: CGFloat = 1
        static let horizontalPadding: CGFloat = 8
        static let borderAnimation: Animation = .easeInOut(duration: 0.15)
    }

    let isInvalid: Bool

    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .focused($isFocused)
            .padding(.horizontal, Constants.horizontalPadding)
            .frame(height: Constants.height)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .strokeBorder(borderColor, lineWidth: Constants.borderWidth)
            )
            .simultaneousGesture(TapGesture().onEnded { isFocused = true })
            .animation(Constants.borderAnimation, value: borderColor)
    }
    
    private var borderColor: Color {
        if isFocused {
            return Color(.primaryLightActive)
        }
        if isInvalid {
            return Color(.primaryLightAccent)
        }
        return Color(.grayscaleLight)
    }
}

extension View {
    
    func borderedField(isInvalid: Bool = false) -> some View {
        modifier(BorderedFieldModifier(isInvalid: isInvalid))
    }
}
