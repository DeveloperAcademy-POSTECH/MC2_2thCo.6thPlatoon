// ScriptTestView.swift
// Pressor
//
// Created by Ha Jong Myeong on 2023/05/09.
//

import SwiftUI

struct InterviewScriptTestView: View {
    @StateObject var viewModel: InterviewViewModel
    @State private var newTitle = ""
    @State private var newContent = ""
    @State private var showEditInterviewScriptView = false
    @State private var editInterviewScriptIndex = 0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.interviewScriptModel.interviewScript.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(viewModel.interviewScriptModel.interviewScript[index].title)
                                .font(.headline)
                            Text(viewModel.interviewScriptModel.interviewScript[index].content)
                        }
                        .onTapGesture {
                            editInterviewScriptIndex = index
                            showEditInterviewScriptView.toggle()
                        }
                    }
                    .onDelete(perform: deleteInterviewScript)
                }
                
                VStack(spacing: 12) {
                    TextField("Enter title", text: $newTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Enter content", text: $newContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        viewModel.createScript(title: newTitle, content: newContent)
                        newTitle = ""
                        newContent = ""
                    }) {
                        Text("Add Interview Script")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
            }
            .navigationTitle("Interview Scripts")
            .sheet(isPresented: $showEditInterviewScriptView) {
                EditInterviewScriptTestView(viewModel: viewModel, index: editInterviewScriptIndex, updatedTitle: viewModel.interviewScriptModel.interviewScript[editInterviewScriptIndex].title, updatedContent: viewModel.interviewScriptModel.interviewScript[editInterviewScriptIndex].content)
            }
        }
    }
    
    private func deleteInterviewScript(at offsets: IndexSet) {
        offsets.forEach { index in
            viewModel.deleteScript(atIndex: index)
        }
    }
}
