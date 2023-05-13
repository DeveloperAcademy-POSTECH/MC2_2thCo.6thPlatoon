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
    
    private var isNotRequestedInfoAllSubmitted: Bool {
        interviewBubbleManager.currentInterview.details.userName.isEmpty || interviewBubbleManager.currentInterview.details.interviewTitle.isEmpty
    }
    
    var body: some View {
        Form {
            Section {
                TextField(
                    "인터뷰 제목",
                    text: $interviewBubbleManager.currentInterview.details.interviewTitle
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
                    text: $interviewBubbleManager.currentInterview.details.userName
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
                    text: $interviewBubbleManager.currentInterview.details.userEmail
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
                TextField(
                    "전화번호",
                    text: $interviewBubbleManager.currentInterview.details.userPhoneNumber
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
                        // 재할당으로 업데이트
                        interviewBubbleManager.currentInterview = self.interviewBubbleManager.currentInterview
                        dismiss()
                    } label: {
                        Text("완료")
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
        }
    }
}
