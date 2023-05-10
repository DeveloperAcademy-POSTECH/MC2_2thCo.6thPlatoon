//
//  Color+.swift
//  Pressor
//
//  Created by Celan on 2023/05/05.
//

import SwiftUI

extension Color {
    /**
     hex 코드기반으로 Color를 생성하는 생성자입니다.
     Color Extension 내부에서 데이터 속성을 선언하기 위해 활용합니다.
     
     - Parameter hex: "#"부터 시작하는 hex code를 받습니다.
     - Author: Celan
     */
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

extension Color {
    static var PressorRed: Self {
        .init(hex: "#FF3B30")
    }
    static var PressorRed_Dark: Self {
        .init(hex: "4D120F")
    }
    static var PressorBlue_Light: Self {
        .init(hex: "B1F2F0")
    }
    static var PressorBlue: Self {
        .init(hex: "00EADF")
    }
    static var PressorOrange_Light: Self {
        .init(hex: "FFDB99")
    }
    static var PressorOrange: Self {
        .init(hex: "FFA600")
    }
    static var BackgroundGray_Dark: Self {
        .init(hex: "2C2C2E")
    }
    static var BackgroundGray_Light: Self {
        .init(hex: "F2F2F7")
    }
    static var SymbolGray: Self {
        .init(hex: "D1D1D6")
    }
    static var DisabledGary: Self {
        .init(hex: "999999")
    }
}
