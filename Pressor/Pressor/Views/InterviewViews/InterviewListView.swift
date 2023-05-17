//
//  InterviewListView.swift
//  Pressor
//
//  Created by sup on 2023/05/03.
//  Refactored by Celan on 2023/05/15.

import SwiftUI

struct InterviewListView: View {
    @EnvironmentObject var interviewListViewModel: InterviewListViewModel
    @StateObject var interviewBubbleManager: InterviewBubbleManager = InterviewBubbleManager()
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    @State private var selectedRows = Set<String>()
    @State private var isEditing = false
    @State private var showAlert = false
    @State private var navigationTitleString = ""
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List(selection: $selectedRows) {
                ForEach(
                    0 ..< interviewListViewModel.interviewList.count,
                    id: \.self
                ) {  index in
                    if
                        let interviewDetail = interviewListViewModel.getEachInterviewDetail(idx: index) {
                        NavigationLink {
                            VStack {
                                InterviewDetailView(
                                    interviewBubbleManager: interviewBubbleManager,
                                    interviewIndex: index
                                )
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(interviewDetail.interviewTitle)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(interviewDetail.date.toString(dateFormat: "yyyy. MM. dd. a HH:mm"))
                                        .font(.subheadline)
                                        .foregroundColor(Color(.systemGray))
                                }
                                
                                Spacer()
                                
                                if
                                    let interview = interviewListViewModel.getEachInterview(idx: index) {
                                    if interview.recordSTT.isEmpty {
                                        Text("변환 중")
                                            .foregroundColor(.PressorOrange)
                                        
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color.pressorSystemGray_dark))
                                    } else {
                                        Text(interviewDetail.playTime)
                                            .font(.headline)
                                            .foregroundColor(Color.pressorSystemGray_dark)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.BackgroundGray_Light)
                        .disabled(interviewListViewModel.getEachInterview(idx: index)?.recordSTT.isEmpty ?? false)
                    } else {
                        Text("NO INTERVIEWS TO SHOW")
                    }
                }
                .onDelete { indexSet in
                    delete(at: indexSet)
                }
            }
            // NavigationView Background적용을 위한 세팅
            .scrollContentBackground(.hidden)
            .background(Color.white) // NavigationView 전체 색상
            .navigationTitle("인터뷰")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            //편집 클릭시 멀티셀렉션 돌아가게 해주는 내용
            .animation(.default, value: isEditing)
            .searchable(text: $searchText, prompt: "Interview 검색")
        }
    }

    private func delete(at offsets: IndexSet) {
        interviewListViewModel.interviewList.remove(atOffsets: offsets)
    }
}
