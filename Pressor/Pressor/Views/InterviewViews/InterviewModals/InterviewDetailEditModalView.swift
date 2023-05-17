//
//  InterviewDetailEditModalView.swift
//  Pressor
//
//  Created by Celan on 2023/05/04.
//

import SwiftUI

struct InterviewDetailEditModalView: View {
    @EnvironmentObject var routingManager: RoutingManager
    @EnvironmentObject var interviewListViewModel: InterviewListViewModel
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var isDetailChanging: Bool
    @State var interview: Interview
    
    @State private var transcribeURLArray: [URL] = []
    
    private var isNotRequestedInfoAllSubmitted: Bool {
        interviewListViewModel.userName.isEmpty || interviewListViewModel.interviewTitle.isEmpty
    }
    
    var body: some View {
        Form {
            Section {
                TextField(
                    "인터뷰 제목",
                    text: $interviewListViewModel.interviewTitle
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
                    text: $interviewListViewModel.userName
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
                    text: $interviewListViewModel.userEmail
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                
                TextField(
                    "전화번호",
                    text: $interviewListViewModel.userPhoneNumber
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
                // NavigationLinked > NavigationView
                if isDetailChanging {
                    Button {
                        updateInterviewDetails(
                            interviewTitle: interviewListViewModel.interviewTitle,
                            userName: interviewListViewModel.userName,
                            userEmail: interviewListViewModel.userEmail,
                            userPhoneNumber: interviewListViewModel.userPhoneNumber
                        )
                        
                        if let idx = interviewListViewModel.interviewList.firstIndex(where: { eachInterview in
                            eachInterview.id == interview.id
                        }) {
                            interviewListViewModel.interviewList[idx] = interview
                        }
                        dismiss()
                    } label: {
                        Text("수정")
                    }
                    .disabled(isNotRequestedInfoAllSubmitted)
                } else {
                    Button {
                        // 선 어펜드
                        interviewListViewModel.completedInterview = interview
                        // MARK: DETAIL 먼저 할당 후, append 시킨다.
                        interviewListViewModel.updateInterviewDetails()
                        interviewListViewModel.interviewList.append(interviewListViewModel.completedInterview)
                        
                        voiceViewModel.initInterview()
                        
                        // urls에 저장된 음성파일의 모든 fileURL추가
                        for record in interviewListViewModel.completedInterview.records {
                            transcribeURLArray.append(record.fileURL)
                        }
                        
                        // STT 시동
                        voiceViewModel.transURLs(urls: transcribeURLArray)
                        
                        // 저장된 걸 보여주고 dismiss 해야 할 것 같은데
                        routingManager.isRecordViewDisplayed = false
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
                interviewListViewModel.updateState(with: interview)
            }
        }
    }
    
    private func isInterviewDetailEditted() -> Bool {
        if !interview.details.interviewTitle.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    private func updateInterviewDetails(
        interviewTitle: String,
        userName: String,
        userEmail: String,
        userPhoneNumber: String
    ) {
        interview.details.interviewTitle = interviewTitle
        interview.details.userName = userName
        interview.details.userEmail = userEmail
        interview.details.userPhoneNumber = userPhoneNumber
    }
}
