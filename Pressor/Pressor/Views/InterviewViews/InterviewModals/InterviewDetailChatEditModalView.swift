//
//  InterviewDetailChatEditModalView.swift
//  Pressor
//
//  Created by Celan on 2023/05/04.
//

import SwiftUI

struct InterviewDetailChatEditModalView: View {
    @ObservedObject var interviewBubbleManager: InterviewBubbleManager
    @EnvironmentObject var interviewListViewModel: InterviewListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var interviewDescription: String = ""
    @Binding var isInterviewDetailChatEditModalViewDisplayed: Bool
    @FocusState var isTextEditorDisplayed: Bool
    
    let transcriptIndex: Int
    let interviewIdx: Int
    
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
                        interviewListViewModel.interviewList[interviewIdx].recordSTT[transcriptIndex] = interviewDescription
                        dismiss()
                        
                    } label: {
                        Text("완료")
                    }
                }
            }
        }
        .onAppear {
            self.interviewDescription = interviewListViewModel.getEachInterview(idx: interviewIdx)?.recordSTT[safe: transcriptIndex] ?? ""
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
