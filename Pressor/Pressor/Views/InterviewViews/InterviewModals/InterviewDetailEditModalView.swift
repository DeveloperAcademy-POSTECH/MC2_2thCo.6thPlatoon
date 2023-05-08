//
//  InterviewDetailEditModalView.swift
//  Pressor
//
//  Created by Celan on 2023/05/04.
//

import SwiftUI

struct InterviewDetailEditModalView: View {
    @State private var interviewTitle: String = Constants.NO_NAME_INTERVIEW
    @State private var intervieweeName: String = ""
    @State private var intervieweeEmail: String = ""
    @State private var intervieweePhoneNumber: String = ""
    @Binding var isInterviewDetailEditModalViewDisplayed: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("인터뷰 제목", text: $interviewTitle)
                } header: {
                    Text("인터뷰 제목")
                }
                
                Section {
                    TextField("이름", text: $intervieweeName)
                        .overlay(alignment: .trailing) {
                            Image(systemName: "asterisk")
                                .font(.caption)
                                .foregroundColor(.PressorRed)
                        }
                    TextField("이메일", text: $intervieweeEmail)
                    TextField("전화번호", text: $intervieweePhoneNumber)
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
            .navigationTitle("인터뷰 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: COREDATA CREATE METHOD HERE
                        dismiss()
                    } label: {
                        Text("완료")
                    }
                    // 인터뷰 참여자의 이름이 비어있으면 '완료' 버튼은 비활성화 된다.
                    .disabled(intervieweeName.isEmpty)
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
