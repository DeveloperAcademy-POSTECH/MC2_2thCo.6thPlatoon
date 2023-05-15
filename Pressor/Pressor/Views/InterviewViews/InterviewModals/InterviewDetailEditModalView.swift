//
//  InterviewDetailEditModalView.swift
//  Pressor
//
//  Created by Celan on 2023/05/04.
//

import SwiftUI

struct InterviewDetailEditModalView: View {
    @ObservedObject var interviewBubbleManager: InterviewBubbleManager
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
            .listRowBackground(Color.BackgroundGray_Light)
            
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
            .listRowBackground(Color.BackgroundGray_Light)
        }
        .scrollContentBackground(.hidden)
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
                        interviewBubbleManager.updateInterviewDetails(
                            interviewTitle: interviewTitle,
                            userName: userName,
                            userEmail: userEmail,
                            userPhoneNumber: userPhoneNumber
                        )
                    } label: {
                        Text("완료")
                    }
                    .onChange(
                        of: interviewBubbleManager.currentInterview.details.interviewTitle
                    ) { _ in
                        dismiss()
                    }
                } else {
                    NavigationLink {
                        InterviewDetailView(
                            interviewBubbleManager: interviewBubbleManager
                        )
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
            interviewBubbleManager.updateInterviewDetails(
                interviewTitle: interviewTitle,
                userName: userName,
                userEmail: userEmail,
                userPhoneNumber: userPhoneNumber
            )
        }
        .onAppear {
            interviewBubbleManager.updateState(
                interviewTitle: &interviewTitle,
                userName: &userName,
                userEmail: &userEmail,
                userPhoneNumber: &userPhoneNumber
            )
        }
    }
    
    private func isInterviewDetailEditted() -> Bool {
        if !interviewBubbleManager.currentInterview.details.interviewTitle.isEmpty {
            return true
        } else {
            return false
        }
    }
}
