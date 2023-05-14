//
//  InterviewTestModel.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/05.
//

import Foundation

struct Interview: Identifiable {
    let id: String = UUID().uuidString
    var details: InterviewDetail
    var records: [Record]
    var recordSTT: [String]
    var script: Script
    
    static func getDummyInterview() -> Self {
        Interview(details: InterviewDetail(interviewTitle: "", userName: "", userEmail: "", userPhoneNumber: "", date: Date(), playTime: ""), records: [], recordSTT: [], script: .init(title: "", description: ""))
    }
}
