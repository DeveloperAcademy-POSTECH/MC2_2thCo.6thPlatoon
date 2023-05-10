//
//  InterviewDetailView.swift
//  Pressor
//
//  Created by Celan on 2023/05/09.
//

import SwiftUI

struct InterviewDetailView: View {
    @ObservedObject var voiceViewModel: VoiceViewModel
    
    @State private var interview: Interview?
    
    @State private var isEditing: Bool = false
    @State private var isInterviewInfoEditing: Bool = false
    @State private var isWholeRecordPlaying: Bool = false
    @State private var isRemovingInterview: Bool = false

    @State private var transferableScripts: String = ""
    @State private var sliderRange: CGFloat = 0
    
    // MARK: - LIFECYCLE
    init(voiceViewModel: VoiceViewModel) {
        self.voiceViewModel = voiceViewModel
        
        // MARK: SET SLIDER THUMB IMAGE
        UISlider.appearance().setThumbImage(
            .init(systemName: "circlebadge.fill"),
            for: .normal
        )
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    if
                        let interview {
                        Section {
                            ForEach(interview.records, id: \.id) { eachRecord in
                                // TODO: DI ViewModel, Record
                                RecordBubble(
                                    voiceViewModel: voiceViewModel,
                                    record: eachRecord,
                                    interview: interview,
                                    isEditing: $isEditing
                                )
                            }
                        } header: {
                            InterviewInfoHeader()
                                .padding(.bottom, 16)
                        }
                    } else {
                        ProgressView()
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.height * 0.2)
            }
            
            VStack {
                // MARK: - AUDIO PLAYER
                AudioPlayerBuilder()
            }
            .frame(
                maxHeight: .infinity,
                alignment: .bottom
            )
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            // TODO: GET Record List Here
            makeTransferableScripts()
        }
        .navigationTitle("INTERVIEW_NAME")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    // TODO: get All Interview Sound Asset to share all data
                    // TODO: DEEPLINK
                    ShareLink(item: transferableScripts) {
                        Label("공유", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        isRemovingInterview.toggle()
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert(isPresented: $isRemovingInterview) {
            Alert(
                title: Text("INTERVIEWNAME을 삭제하시겠습니까?"),
                message: Text("이 동작은 취소되지 않습니다."),
                primaryButton: .default(
                    Text("취소하기")
                ),
                secondaryButton: .destructive(
                    Text("삭제하기")
                ) {
                    // TODO: REMOVE INTERVIEW CRUD HERE
                    print("\(#filePath) L: \(#line) REMOVE INTERVIEW CRUD HERE")
                }
            )
        }
        .sheet(isPresented: $isInterviewInfoEditing) {
            InterviewDetailEditModalView(
                isInterviewDetailEditModalViewDisplayed: $isInterviewInfoEditing
            )
        }
    }
    
    // MARK: METHODS
    private func InterviewInfoHeader() -> some View {
        VStack {
            VStack(spacing: 12) {
                HStack {
                    Text("INTERVEIW_NAME")
                        .bold()
                    Spacer()
                    Button {
                        isInterviewInfoEditing.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .tint(Color.pressorRed)
                }
                
                HStack {
                    Text("INTERVIEW_DATE")
                    Spacer()
                    Text("INTERVIEW_TOTAL_LENGTH")
                }
                .bold()
                .font(.footnote)
                .foregroundColor(Color(.systemGray2))
            }
            
            Divider()
                .padding(.vertical, 7.5)
            
            HStack(spacing: 28) {
                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    HStack {
                        Text("Name")
                    }
                    
                    HStack {
                        Text("Email")
                    }
                    
                    HStack {
                        Text("Phone")
                    }
                }
                .bold()
                .foregroundColor(Color(.systemGray2))
                
                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    HStack {
                        Text("INTERVIEWEE_NAME")
                            .bold()
                    }
                    
                    HStack {
                        Text("INTERVIEWEE_EMAIL")
                            
                    }
                    
                    HStack {
                        Text("INTERVIEWEE_PHONE")
                    }
                }
            }
            .font(.callout)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .padding()
        // MARK: Sketch는 한 줄 이상을 받아오는 시나리오가 없기에 각 정보는 한 줄로 보여지도록 제한합니다.
        .lineLimit(1)
        .frame(
            width: UIScreen.main.bounds.width * 0.925,
            height: UIScreen.main.bounds.height * 0.225
        )
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.pressorSystemGray)
        }
    }
    
    private func makeTransferableScripts() {
        if
            let interview {
            for idx in 0..<interview.recordSTT.count {
                if idx % 2 == 0 {
                    // 먼저 질문하는 사람이 인터뷰어가 된다.
                    self.transferableScripts += ("인터뷰어: " + interview.recordSTT[idx])
                } else {
                    self.transferableScripts += ("INTERVIEWEE_NAME: " + interview.recordSTT[idx])
                }
            }
        }
    }
    
    @ViewBuilder
    private func AudioPlayerBuilder() -> some View {
        ZStack {
            Rectangle()
                .fill(.clear)
                .background {
                    BlurBackground()
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: UIScreen.main.bounds.height * 0.2
                )
            
            VStack {
                // MARK: PLAY PROGRESS
                // SLIDER....
                VStack(spacing: 0) {
                    Slider(value: $sliderRange)
                    
                    HStack {
                        Text("시작")
                        Spacer()
                        Text("끝")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // MARK: PLAY BUTTONS
                HStack(spacing: 40) {
                    Button {
                        print("\(#file) L: \(#line) GO BACK 10 SECONDS")
                    } label: {
                        Rectangle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.clear)
                            .overlay {
                                Image(systemName: "gobackward.10")
                                    .font(.title3)
                            }
                    }
                    .buttonStyle(.borderless)
                    
                    Button {
                        isWholeRecordPlaying.toggle()
                    } label: {
                        Rectangle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.clear)
                            .overlay {
                                Image(systemName: isWholeRecordPlaying ? "pause.fill" : "play.fill")
                                    .font(.title3)
                            }
                    }
                    
                    Button {
                        print("\(#file) L: \(#line) SKIP 10 SECONDS")
                    } label: {
                        Rectangle()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.clear)
                            .overlay {
                                Image(systemName: "goforward.10")
                                    .font(.title3)
                            }
                        
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.bottom, 24)
            }
            .tint(.pressorRed)
        }
    }
}

struct InterviewDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InterviewDetailView(voiceViewModel: VoiceViewModel())
        }
    }
}
