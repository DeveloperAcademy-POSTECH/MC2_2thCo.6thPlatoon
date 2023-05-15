//
//  InterviewTestModel.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/05.
//

import Foundation

struct Interview: Identifiable, Codable {
    let id: String = UUID().uuidString
    var details: InterviewDetail
    var records: [Record]
    var recordSTT: [String]
    var script: Script
    
    static func getDummyInterview() -> Self {
        Interview(details: InterviewDetail(interviewTitle: "123", userName: "123", userEmail: "asd", userPhoneNumber: "asd", date: Date(), playTime: "45"), records: [], recordSTT: [], script: .init(title: "title", description: "4543543543435"))
    }
}
