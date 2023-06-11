//
//  MainRecordView.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI

struct MainRecordView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var routingManager: RoutingManager
    @EnvironmentObject var interviewListViewModel: InterviewListViewModel
    @EnvironmentObject var vm: VoiceViewModel
    @ObservedObject var permissionManager: PermissionManager = .init()
    @StateObject var interviewViewModel = InterviewViewModel()
    
    @State var isSheetShowing: Bool = false
    @State var isShowingScriptDeleteAlert = false
    @State var showModal = false
    @State var scriptAdded: Bool = false
    @State var navigateToNextView = false
    @State var countSec: Int = 0
    @State var timerCount : Timer?
    @State var isTimerCounting: Bool = false
    @State private var currentTab: String = Constants.RECORD_TAB_ID
    @State private var scriptTitle: String = ""
    @State private var scriptDescription: String = ""
    @State private var scriptMode: ScriptMode = .add
    @State private var isShowingSettingView = false
    
    @State private var micPermissionCheck: Bool = false
    @State private var STTPermissionCheck: Bool = false
    
    private var isRecordingSTTTranscribing: Bool {
        interviewListViewModel.completedInterview.recordSTT.isEmpty &&
        !interviewListViewModel.completedInterview.details.interviewTitle.isEmpty
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $routingManager.currentTab) {
                NavigationView {
                    ZStack {
                        VStack {
                            Text(isRecordingSTTTranscribing ? "변환중인 인터뷰가 있습니다.\n잠시만 기다려 주세요." : "새로운 인터뷰 녹음을 시작하려면\n아래 녹음 버튼을 눌러주세요.")
                                .font(.headline)
                                .foregroundColor(Color(red: 193/255, green: 193/255, blue: 200/255))
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.bottom, 50)
                            
                            VStack {
                                // MARK: - Mic Button
                                Button {
                                    if !isTimerCounting && micPermissionCheck && STTPermissionCheck {
                                        // 권한 체크
                                        countSec = 3
                                        isTimerCounting.toggle()
                                        timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                                            print(countSec)
                                            self.countSec -= 1
                                            if countSec == 0 {
                                                timerCount?.invalidate()
                                                // MARK: 대본이 있다면 추가시키는 로직
                                                vm.interview.script = interviewViewModel.getScript()
                                                routingManager.isRecordViewDisplayed.toggle()
                                                isTimerCounting.toggle()
                                            }
                                        })
                                    } else {
                                        self.micPermissionCheck = permissionManager.requestMicPermission()
                                        self.STTPermissionCheck = permissionManager.requestSpeechRecognizerPermission()
                                        
                                        // 권한 요청이 완료된 후에 조건을 다시 확인
                                        DispatchQueue.main.async {
                                            if !isTimerCounting && micPermissionCheck && STTPermissionCheck {
                                                countSec = 3
                                                isTimerCounting.toggle()
                                                timerCount = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (value) in
                                                    print(countSec)
                                                    self.countSec -= 1
                                                    if countSec == 0 {
                                                        timerCount?.invalidate()
                                                        // MARK: 대본이 있다면 추가시키는 로직
                                                        vm.interview.script = interviewViewModel.getScript()
                                                        routingManager.isRecordViewDisplayed.toggle()
                                                        isTimerCounting.toggle()
                                                    }
                                                })
                                            } else {
                                                // MARK: 시점차이로 인해 micPermissionCheck와 STTPermissionCheck이 먼저 true로 설정되어도 마지막 else 구문에서 self.showPermissionAlert()가 실행되는 문제때문에 써줌
                                                DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                                                    if !micPermissionCheck || !STTPermissionCheck {
                                                        self.showPermissionAlert()
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                } label: {
                                    Image(isRecordingSTTTranscribing ? "mic_button_disable" : "mic_button")
                                        .padding(.bottom, 40)
                                }
                                .disabled(
                                    isRecordingSTTTranscribing
                                )
                                .fullScreenCover(isPresented: $routingManager.isRecordViewDisplayed) {
                                    if scriptAdded {
                                        InterviewRecordingScriptView()
                                    } else {
                                        InterviewRecordingView()
                                    }
                                }
                            }
                            
                            VStack {
                                Button {
                                    if scriptAdded {
                                        self.isSheetShowing = true
                                    } else {
                                        showModal.toggle()
                                    }
                                } label: {
                                    if scriptAdded {
                                        // 대본이 있을 경우
                                        VStack {
                                            Image(systemName: "note.text")
                                                .resizable()
                                                .frame(width: 35, height: 33)
                                                .foregroundColor(Color.orange)
                                            Text("대본 확인")
                                                .foregroundColor(Color.SymbolGray)
                                        }
                                    } else {
                                        // 대본이 없을 경우
                                        VStack {
                                            Image(systemName: "note.text.badge.plus")
                                                .resizable()
                                                .frame(width: 42, height: 35)
                                                .foregroundColor(Color.orange)
                                                .padding(.leading, 5)
                                            Text("대본 추가")
                                                .foregroundColor(Color.SymbolGray)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                }
                                .fullScreenCover(isPresented: $isSheetShowing) {
                                    CheckScriptView(interviewViewModel: interviewViewModel, scriptAdded: $scriptAdded)
                                }
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Image("app_logo")
                                    .foregroundColor(.clear)
                                    .padding(0)
                                
                            }
                            
//                            ToolbarItem(placement: .navigationBarTrailing) {
//                                NavigationLink {
//                                    SettingView(isShowingSettingView: $isShowingSettingView)
//                                        .toolbar(isShowingSettingView ? .hidden : .visible, for: .tabBar)
//                                } label: {
//                                    Image(systemName: "gearshape.fill")
//                                        .foregroundColor(.SymbolGray)
//                                }
//                                .navigationBarTitleDisplayMode(.inline)
//                                .navigationBarHidden(true)
//                            }
                        }
                        .disabled(isTimerCounting)
                        
                        if isTimerCounting {
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
                                    .foregroundColor(.orange)
                                    .fontDesign(.rounded)
                                    .padding(.bottom, 8)
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showModal) {
                        AddScriptView(interviewViewModel: interviewViewModel, scriptAdded: $scriptAdded)
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
            .accentColor(.orange)
            .onAppear {
                UITabBar.appearance().scrollEdgeAppearance = .init()
            }
        }
    }
    
    private func showPermissionAlert() {
        let allScenes = UIApplication.shared.connectedScenes
        let scene = allScenes.first { $0.activationState == .foregroundActive }
        let NOTIalert: UIAlertController = UIAlertController(title: "마이크와 음성 인식 권한 설정", message: "서비스 이용을 위해 마이크와 음성 인식 권한을 허용해주세요.", preferredStyle: .alert)
        let NOTIaction: UIAlertAction = UIAlertAction(title: "설정 변경", style: .default, handler: { (ACTION) in
            //앱 설정 이동
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        NOTIalert.addAction(NOTIaction)
        DispatchQueue.main.async{
            if #available(iOS 15, *) {
                if let windowScene = scene as? UIWindowScene {
                    windowScene.keyWindow?.rootViewController?.present(NOTIalert, animated: true, completion: nil)
                }
            } else {
                UIApplication.shared.keyWindow?.rootViewController?.present(NOTIalert, animated: true, completion: nil)
            }
        }
    }
}

