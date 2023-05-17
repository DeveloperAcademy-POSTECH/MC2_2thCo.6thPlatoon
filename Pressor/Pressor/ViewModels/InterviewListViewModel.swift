//
//  InterviewListViewModel.swift
//  Pressor
//
//  Created by Celan on 2023/05/15.
//

import SwiftUI
import Combine

final class InterviewListViewModel: ObservableObject {
    @AppStorage(Constants.USERDEFAULTS_INTERVIEWS_KEY)
    var interviewList: [Interview] = []
    
    @Published var completedInterview: Interview = .getInitInterview()
    @Published var isUpdatingDetails: Bool = false
    
    @Published var interviewTitle: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhoneNumber: String = ""
    
    public func getEachInterview(idx: Int) -> Interview? {
        if interviewList.count > 0 {
            return self.interviewList[safe: idx]
        } else {
            return nil
        }
    }
    
    public func getEachInterviewDetail(idx: Int) -> InterviewDetail? {
        if interviewList.count > 0 {
            return self.interviewList[safe: idx]?.details
        } else {
            return nil
        }
    }
    
    public func getEachInterviewRecordList(idx: Int) -> [Record]? {
        if interviewList.count > 0 {
            return self.interviewList[safe: idx]?.records
        } else {
            return nil
        }
    }
    
    public func updateInterviewDetails() {
        self.completedInterview.details.interviewTitle = interviewTitle
        self.completedInterview.details.userName = userName
        self.completedInterview.details.userEmail = userEmail
        self.completedInterview.details.userPhoneNumber = userPhoneNumber
        initState()
    }
    
    public func updateState(with interview: Interview) {
        self.interviewTitle = interview.details.interviewTitle
        self.userName = interview.details.userName
        self.userEmail = interview.details.userEmail
        self.userPhoneNumber = interview.details.userPhoneNumber
    }
    
    private func initState() {
        interviewTitle = ""
        userName = ""
        userEmail = ""
        userPhoneNumber = ""
    }
}
