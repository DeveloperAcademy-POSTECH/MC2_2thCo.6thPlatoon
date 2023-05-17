//
//  InterviewListView.swift
//  Pressor
//
//  Created by sup on 2023/05/03.
//  Refactored by Celan on 2023/05/15.

import SwiftUI

struct InterviewListView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var interviewListViewModel: InterviewListViewModel
    @EnvironmentObject var routeManager: RoutingManager
    @StateObject var interviewBubbleManager: InterviewBubbleManager = InterviewBubbleManager()
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    @State private var selectedRows = Set<String>()
    @State private var showAlert = false
    @State private var navigationTitleString = ""
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            if interviewListViewModel.interviewList.count > 0 {
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
                                                    .font(.subheadline)
                                                    .padding(.horizontal)
                                                
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.pressorSystemGray_dark))
                                            } else {
                                                Text(interviewDetail.playTime)
                                                    .font(.subheadline)
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
                .toolbar {
                    EditButton()
                }
                .scrollContentBackground(.hidden)
                .background(Color.white) // NavigationView 전체 색상
                .searchable(text: $searchText, prompt: "Interview 검색")
                .navigationTitle("인터뷰")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                Image("EmptyInterview")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .navigationTitle("인터뷰")
                    .navigationBarTitleDisplayMode(.inline)
            }
            //편집 클릭시 멀티셀렉션 돌아가게 해주는 내용
        }
        .onAppear {
            interviewListViewModel.interviewList.sort { lhs, rhs in
                lhs.details.date > rhs.details.date
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        interviewListViewModel.interviewList.remove(atOffsets: offsets)
    }
}
