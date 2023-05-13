//
//  InterviewDetailChatEditModalView.swift
//  Pressor
//
//  Created by Celan on 2023/05/04.
//

import SwiftUI

struct InterviewDetailChatEditModalView: View {
    @ObservedObject var interviewBubbleManager: InterviewBubbleManager
    @State var record: Record
    @State private var interviewDescription: String = ""
    @Binding var isInterviewDetailChatEditModalViewDisplayed: Bool
    @FocusState var isTextEditorDisplayed: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextEditor(text: $interviewDescription)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .frame(
                        minHeight: UIScreen.main.bounds.height * 0.5,
                        maxHeight: .infinity
                    )
                    .focused($isTextEditorDisplayed)
                    .task {
                        isTextEditorDisplayed = true
                    }
            }
            .navigationTitle("편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        hideKeyboard()
                        dismiss()
                    } label: {
                        Text("취소")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        hideKeyboard()
                        dismiss()
                        // TODO: RECORD TEXT UPDATE HERE
                        interviewBubbleManager.currentInterview.recordSTT[record.transcriptIndex] = interviewDescription
                    } label: {
                        Text("완료")
                    }
                }
            }
        }
        .onAppear {
            self.interviewDescription =  interviewBubbleManager.currentInterview.recordSTT[record.transcriptIndex]
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onDisappear {
            hideKeyboard()
        }
    }
}

//struct InterviewDetailChatEditModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        InterviewDetailChatEditModalView()
//    }
//}
