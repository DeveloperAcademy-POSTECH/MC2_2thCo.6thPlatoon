//
//  Array+SafeIndex.swift
//  Pressor
//
//  Created by Celan on 2023/05/12.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        // iOS 9 or later
        return indices ~= index ? self[index] : nil
    }
}

