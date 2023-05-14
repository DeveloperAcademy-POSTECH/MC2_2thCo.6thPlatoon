//
//  MainRecordView.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI

struct MainRecordView: View {
    @EnvironmentObject var routingManager: RoutingManager
    @ObservedObject var vm: VoiceViewModel
    @StateObject var interviewViewModel = InterviewViewModel()
    
    @State var isSheetShowing: Bool = false
    @State var isShowingAlert = false
    @State var showModal = false
    @State var scriptAdded: Bool = false
    @State var navigateToNextView = false
    @State var isShownInterviewRecordingView = false
    @State var selectedScriptIndex: Int = 0
    @State var countSec: Int = 0
    @State var timerCount : Timer?
    @State var isTimerCounting: Bool = false
    @State private var currentTab: String = Constants.RECORD_TAB_ID
        
    var body: some View {
        TabView(selection: $routingManager.currentTab) {
            NavigationView {
                ZStack {
                    VStack {
                        Text("새로운 인터뷰 녹음을 시작하려면\n아래 녹음 버튼을 눌러주세요.")
                            .font(.headline)
                            .foregroundColor(Color(red: 193/255, green: 193/255, blue: 200/255))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.bottom, 50)
                        
                        VStack {
                            // MARK: - Mic Button
                            Button {
                                
                                if !isTimerCounting {
                                    countSec = 3
                                    isTimerCounting.toggle()
                                    timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                                        print(countSec)
                                        self.countSec -= 1
                                        if(countSec == 0){
                                            timerCount?.invalidate()
                                            self.isShownInterviewRecordingView.toggle()
                                            isTimerCounting.toggle()
                                        }
                                    })
                                    
                                }
                            } label: {
                                Image("mic_button")
                                    .padding(.bottom, 40)
                            }
                            .fullScreenCover(isPresented: $isShownInterviewRecordingView) {
                                InterviewRecordingView(vm: vm, isShownInterviewRecordingView: $isShownInterviewRecordingView)
                            }
                            .simultaneousGesture(TapGesture().onEnded{
                                vm.initInterview()
                                print(vm.interview)
                            })
                        }
                        
                        VStack {
                            Button {
                                if scriptAdded {
                                    self.isSheetShowing = true
                                    scriptAdded = true
                                } else {
                                    showModal.toggle()
                                    scriptAdded = false
                                }
                            } label: {
                                if scriptAdded {
                                    // 대본이 있을 경우
                                    VStack {
                                        Image(systemName: "note.text")
                                            .resizable()
                                            .frame(width: 35, height: 33)
                                            .foregroundColor(Color.accentColor)
                                        
                                        Text("대본편집")
                                            .foregroundColor(Color.accentColor)
                                    }
                                    .confirmationDialog("타이틀", isPresented: $isSheetShowing) {
                                        Button("대본 삭제", role: .destructive) {
                                            isSheetShowing = false
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                isShowingAlert = true
                                            }
                                        }
                                        
                                        Button("대본 수정", role: .destructive) {
                                            showModal = true
                                            selectedScriptIndex = 0
                                        }
                                        .sheet(isPresented: $showModal) {
                                            AddScriptModalView(mode: .edit, scriptAdded: $scriptAdded, interviewViewModel: interviewViewModel, scriptIndex: selectedScriptIndex)
                                        }
                                        
                                        Button("취소", role: .cancel) {
                                            
                                        }
                                    }
                                    .alert(isPresented: $isShowingAlert) {
                                        Alert(
                                            title: Text("대본 삭제"),
                                            message: Text("정말로 이 대본을 삭제하시겠습니까?"),
                                            primaryButton: .destructive(Text("삭제")) {
                                                interviewViewModel.deleteScript(atIndex: selectedScriptIndex)
                                                scriptAdded = false
                                            },
                                            secondaryButton: .cancel(Text("취소"))
                                        )
                                    }
                                } else {
                                    // 대본이 없을 경우
                                    VStack {
                                        Image(systemName: "note.text.badge.plus")
                                            .resizable()
                                            .frame(width: 42, height: 35)
                                            .foregroundColor(Color.accentColor)
                                            .padding(.leading, 5)
                                        
                                        Text("대본 추가")
                                            .foregroundColor(Color.accentColor)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                    }
                    if countSec != 0 {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .frame(width: 100, height: 100)
                            Rectangle()
                                .fill(Color.gray)
                                .ignoresSafeArea()
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                .opacity(0.001)
                                .onTapGesture {
                                    isTimerCounting.toggle()
                                    timerCount?.invalidate()
                                    countSec = 0
                                    // TODO: 녹음을 취소하므로 path에서 해당하는 디렉토리 지우기
                                }
                            Text("\(countSec)")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.red)
                                .fontDesign(.rounded)
                                .padding(.bottom, 8)
                        }
                    }
                }
                .navigationBarItems(trailing: NavigationLink(
                    destination: Text("세팅뷰")) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.DisabledGary)
                    }
                )
                .disabled(isTimerCounting)
                .sheet(isPresented: $showModal) {
                    AddScriptModalView(mode: scriptAdded ? .edit : .add, scriptAdded: $scriptAdded, interviewViewModel: interviewViewModel, scriptIndex: selectedScriptIndex)
                }
            }
            .navigationViewStyle(.stack)
            .tag(Constants.RECORD_TAB_ID)
            .tabItem {
                Image(systemName: "mic.circle.fill")
                Text("녹음")
            }
            
            InterviewListView()
                .tag(Constants.INTERVIEW_TAB_ID)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait")
                    Text("인터뷰")
                }
        }
        .accentColor(.red)
        .onAppear {
            UITabBar.appearance().scrollEdgeAppearance = .init()
            vm.initInterview()
        }
    }
}

struct MainRecordView_Previews: PreviewProvider {
    static var previews: some View {
        MainRecordView(vm: VoiceViewModel(interview: .getDummyInterview()))
    }
}
