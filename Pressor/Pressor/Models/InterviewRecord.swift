//
//  InterviewRecord.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/04.
//

import Foundation

// 인터뷰 기록 구조체
struct InterviewRecord: Codable, Identifiable {
    let id: UUID
    let subject: String
    let email: String
    let date: Date
    let phoneNum: String
    let intervieweeName: String
    let interviewSTTRecords: [InterviewSTTRecord]
    
    // 인터뷰 STT 기록들의 총 시간 계산
    var time: TimeInterval {
        return interviewSTTRecords.reduce(0) { sum, record in
            return sum + record.duration
        }
    }
    
    // 인터뷰 STT 기록들의 총 텍스트 합치기
    var text: String {
        return interviewSTTRecords.reduce("") { sum, record in
            return sum + "\n" + record.text
        }
    }
}

// 인터뷰 STT 기록 구조체
struct InterviewSTTRecord: Codable {
    let duration: TimeInterval
    let text: String
}
