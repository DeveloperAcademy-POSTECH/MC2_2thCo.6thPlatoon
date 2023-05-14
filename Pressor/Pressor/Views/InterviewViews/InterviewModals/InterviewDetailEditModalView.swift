//
//  InterviewDetailEditModalView.swift
//  Pressor
//
//  Created by Celan on 2023/05/04.
//

import SwiftUI

struct InterviewDetailEditModalView: View {
    @StateObject var interviewBubbleManager: InterviewBubbleManager
    @EnvironmentObject var routingManager: RoutingManager
    @Environment(\.dismiss) var dismiss
    @Binding var isDetailChanging: Bool
    
    @State private var interviewTitle: String = ""
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var userPhoneNumber: String = ""
    
    private var isNotRequestedInfoAllSubmitted: Bool {
        userName.isEmpty || interviewTitle.isEmpty
    }
    
    var body: some View {
        Form {
            Section {
                TextField(
                    "인터뷰 제목",
                    text: $interviewTitle
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "asterisk")
                            .font(.caption)
                            .foregroundColor(Color.pressorRed)
                    }
            } header: {
                Text("인터뷰 제목")
            }
            
            Section {
                TextField(
                    "이름",
                    text: $userName
                )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "asterisk")
                            .font(.caption)
                            .foregroundColor(.pressorRed)
                    }
                
                TextField(
                    "이메일",
                    text: $userEmail
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
                TextField(
                    "전화번호",
                    text: $userPhoneNumber
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
            } header: {
                Text("대상자 정보")
            } footer: {
                HStack(spacing: 0) {
                    Image(systemName: "asterisk")
                        .font(.caption)
                    Text("는 필수 입력 정보입니다.")
                }
            }
        }
        .navigationTitle(
            isDetailChanging
            ? "인터뷰 수정하기"
            : "인터뷰 정보"
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isDetailChanging {
                    Button {
                        updateInterviewDetails()
                        dismiss()
                    } label: {
                        Text("완료")
                    }
                } else {
                    NavigationLink {
                        InterviewDetailView(
                            interviewBubbleManager: interviewBubbleManager
                        )
                        .onAppear {
                            updateInterviewDetails()
                        }
                    } label: {
                        Text("완료")
                    }
                    // 인터뷰 참여자의 이름이 비어있으면 '완료' 버튼은 비활성화 된다.
                    .disabled(isNotRequestedInfoAllSubmitted)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onDisappear {
            hideKeyboard()
        }
        .onAppear {
            if isDetailChanging {
                updateState()
            }
        }
    }
    
    private func updateState() {
        interviewTitle = interviewBubbleManager.currentInterview.details.interviewTitle
        userName = interviewBubbleManager.currentInterview.details.userName
        userEmail = interviewBubbleManager.currentInterview.details.userEmail
        userPhoneNumber = interviewBubbleManager.currentInterview.details.userPhoneNumber
    }
    
    private func updateInterviewDetails() {
        interviewBubbleManager.currentInterview.details.interviewTitle = interviewTitle
        interviewBubbleManager.currentInterview.details.userName = userName
        interviewBubbleManager.currentInterview.details.userEmail = userEmail
        interviewBubbleManager.currentInterview.details.userPhoneNumber = userPhoneNumber
    }
    
    private func isInterviewDetailEditted() -> Bool {
        if !interviewBubbleManager.currentInterview.details.interviewTitle.isEmpty {
            return true
        } else {
            return false
        }
    }
}
