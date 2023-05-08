//
//  Date+.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/08.
//

import Foundation

extension Date
{
    func toString(dateFormat format: String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "ko_KR") // 로케일 변경
        return dateFormatter.string(from: self)
    }
}
