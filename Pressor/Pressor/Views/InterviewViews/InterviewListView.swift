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
    @State private var isSelected: Bool = false
    @State private var isEditing: Bool = false
    @State private var selectedInterview: [Interview] = []
    
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
                                    InterviewDetailLabel(
                                        isEditing: $isEditing,
                                        selectedInterview: $selectedInterview,
                                        index: index
                                    )
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
                    if isEditing {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                withAnimation {
                                    isEditing.toggle()
                                }
                            } label: {
                                Text("취소")
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if isEditing {
                                for target in selectedInterview {
                                    for interview in interviewListViewModel.interviewList {
                                        if interview.id == target.id {
                                            if let targetIndex = interviewListViewModel.interviewList.firstIndex(of: interview) {
                                                interviewListViewModel.interviewList.remove(at: targetIndex)
                                            }
                                        }
                                    }
                                }
                                
                                withAnimation {
                                    isEditing.toggle()
                                    selectedInterview = []
                                }
                            } else {
                                withAnimation {
                                    isEditing.toggle()
                                }
                            }
                        } label: {
                            Text(isEditing ? "삭제" : "편집")
                                .foregroundColor(isEditing ? Color.pressorRed : Color.PressorOrange)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.white) // NavigationView 전체 색상
                .searchable(text: $searchText, prompt: "Interview 검색")
                .navigationTitle(isEditing ? "\(selectedInterview.count)개의 인터뷰 선택됨" : "인터뷰")
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
        .onDisappear {
            isEditing = false
            selectedInterview = []
        }
    }

    private func delete(at offsets: IndexSet) {
        // MARK: FileManager에서 해당하는 파일 트래킹하여 삭제 후 interviewList에서 remove 시켜주기
        if let index = offsets.last {
            if let interview = interviewListViewModel.getEachInterview(idx: index){
                voiceViewModel.deleteInterview(with: interview)
            }
        }
        
        interviewListViewModel.interviewList.remove(atOffsets: offsets)
    }
    
}

struct InterviewDetailLabel: View {
    @EnvironmentObject var interviewListViewModel: InterviewListViewModel
    @Binding var isEditing: Bool
    @Binding var selectedInterview: [Interview]
    @State private var isSelected: Bool = false
    
    let index: Int
    
    var body: some View {
        HStack {
            if isEditing {
                Toggle(isOn: $isSelected) {
                    EmptyView()
                }
                .toggleStyle(CircleToggleStyle())
                .padding(.trailing)
                .onDisappear {
                    isSelected = false
                }
                .onChange(of: isSelected) { _ in
                    if isSelected {
                        self.selectedInterview.append(interviewListViewModel.interviewList[index])
                    } else {
                        if
                            let removeIndex = self.selectedInterview.firstIndex(of: interviewListViewModel.interviewList[index]) {
                            self.selectedInterview.remove(at: removeIndex)
                            
                            isSelected = false
                        }
                    }
                }
            }
            
            if
                let interviewDetail = interviewListViewModel.getEachInterviewDetail(idx: index) {
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
                            .foregroundColor(Color(.systemGray))
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                }
            }
        }
    }
}
