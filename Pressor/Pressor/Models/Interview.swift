//
//  InterviewTestModel.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/05.
//

import Foundation

struct Interview {
    let id: String = UUID().uuidString
    var details: InterviewDetail
    var records: [Record]
    var recordSTT: [String]
}
