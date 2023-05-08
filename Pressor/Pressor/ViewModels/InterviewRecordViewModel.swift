//  InterviewRecordViewModel.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/04.
//

import Foundation
import SwiftUI
import Combine

class InterviewRecordViewModel: ObservableObject {
    @Published var interviewTitle: String = "새로운 인터뷰"
    @Published var intervieweeName: String = ""
    @Published var email: String = ""
    @Published var phoneNum: String = ""
    
    // 각 필드의 초기값
    private let initialInterviewTitle = ""
    private let initialIntervieweeName = ""
    private let initialEmail = ""
    private let initialPhoneNum = ""
    
    // 모든 필드가 초기값과 동일한 경우 Done 버튼 비활성화
    var isDoneButtonDisabled: Bool {
        interviewTitle == initialInterviewTitle &&
        intervieweeName == initialIntervieweeName &&
        email == initialEmail &&
        phoneNum == initialPhoneNum
    }
    
    // 인터뷰 기록 저장 함수
    func saveInterviewRecord() {
        // STT 기록 추가
        let sttRecords = [InterviewSTTRecord(duration: 0, text: "")]
        // interviewRecord를 데이터 저장소에 저장
        let interviewRecord = InterviewRecord(id: UUID(),
                                              subject: interviewTitle,
                                              email: email,
                                              date: Date(),
                                              phoneNum: phoneNum,
                                              intervieweeName: intervieweeName,
                                              interviewSTTRecords: sttRecords)
    }
}
