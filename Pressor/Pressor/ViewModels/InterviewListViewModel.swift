//
//  InterviewListViewModel.swift
//  Pressor
//
//  Created by Celan on 2023/05/15.
//

import SwiftUI

final class InterviewListViewModel: ObservableObject {
    @AppStorage(Constants.USERDEFAULTS_INTERVIEWS_KEY) var interviewList: [Interview] = []
    @Published var currentInterview: Interview = .getDummyInterview()
    
    public func getEachInterview(idx: Int) -> Interview? {
        if interviewList.count > 0 {
            return self.interviewList[idx]
        } else {
            return nil
        }
    }
    
    public func getEachInterviewDetail(idx: Int) -> InterviewDetail? {
        if interviewList.count > 0 {
            return self.interviewList[idx].details
        } else {
            return nil
        }
    }
    
    public func getEachInterviewRecordList(idx: Int) -> [Record]? {
        if interviewList.count > 0 {
            return self.interviewList[idx].records
        } else {
            return nil
        }
    }
}
