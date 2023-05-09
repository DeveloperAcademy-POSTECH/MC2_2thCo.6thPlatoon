//
//  StartTestView.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/03.
//

import SwiftUI

struct MainTestView: View {
    @ObservedObject var vm: VoiceViewModel
    @State var isTapped: Bool = false
    @State var isSheetShowing: Bool = false
    @State var isShowingAlert = false
    @State var count = 3
    @State var isShownFullScreenCover = false
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    Text("새로운 인터뷰를 시작하려면\n아래 녹음 버튼을 눌러주세요.")
                        .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))
                        .fontWeight(.semibold)
                        .padding(.bottom, 67)
                    VStack {
                        Button {
                            self.isShownFullScreenCover.toggle()
                        } label: {
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .frame(width: 216, height: 216)
                                        .cornerRadius(88)
                                        .foregroundColor(Color(red: 248/255, green: 248/255, blue: 249/255, opacity: 1))
                                    Rectangle()
                                        .frame(width: 182, height: 182)
                                        .cornerRadius(70)
                                        .foregroundColor(Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 1))
                                        .shadow(color: Color.gray.opacity(0.4), radius: 30, x: 0, y: 0)
                                    Rectangle()
                                        .frame(width: 154, height: 154)
                                        .cornerRadius(57)
                                        .foregroundColor(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 57)
                                                .strokeBorder(Color.red, lineWidth: 3)
                                        )
                                    Image(systemName: "mic.fill")
                                        .resizable()
                                        .frame(width: 38, height: 60)
                                        .foregroundColor(Color.red)
                                }
                                .padding(.bottom, 67)
                            }
                        }
                        .fullScreenCover(isPresented: $isShownFullScreenCover) {
                            InterviewRecordingTestView(vm: vm)
                        }
                        .simultaneousGesture(TapGesture().onEnded{
                            //메인뷰에서 마이크를 탭하는 시점에서 Interview 인스턴스를 생성하도록 변경
                            let fileManager = FileManager.default
                            let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            
                            // TODO: > Flow?  directoryPath가 계속 새로 만들어져야함
                            // 인터뷰를 끝내고 저장한다면 해당디렉토리에 파일을 저장하게 냅둠
                            // 인터뷰를 끝내고 저장을 하지 않는다면 삭제함
                            
                            // TODO: 새로운 Interview 인스턴스 생성
                            // TODO: 인터뷰 저장하지 않을 시 해당 경로의 모든 정보 삭제해야함
                            let interview: Interview = Interview(details: InterviewDetail(interviewTitle: "", userName: "", userEmail: "", userPhoneNumber: "", date: Date(), playTime: ""), records: [], recordSTT: [])
                            let interviewId = interview.id
                            let directoryPath = documentUrl.appendingPathComponent("\(interviewId)")
                            
                            do {
                                try fileManager.removeItem(atPath: directoryPath.path)
                            } catch {
                                print("Can't delete")
                            }
                            
                            do {
                                if !fileManager.fileExists(atPath: directoryPath.path) {
                                    try fileManager.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: false, attributes: nil)
                                }
                            } catch {
                                print("create folder error. do something")
                            }
                            
                            vm.interviewPath = directoryPath
                            print(vm.interviewPath)
                            
                        })
                    }
                    
                    VStack {
                        Button(action: {
                            self.isTapped.toggle()
                            self.isSheetShowing = true
                        }) {
                            if self.isTapped {
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
                                        self.isShowingAlert = true
                                    }
                                    .alert(isPresented: $isShowingAlert) {
                                        Alert(title: Text("대본 삭제"),
                                              message: Text("대본을 정말 삭제하시겠습니까?"),
                                              dismissButton: .default(Text("OK")))
                                    }
                                    Button("대본 수정", role: .destructive) {
                                        
                                    }
                                    Button("취소", role: .cancel) {
                                        
                                    }
                                }
                            } else {
                                VStack {
                                    Image(systemName: "note.text.badge.plus")
                                        .resizable()
                                        .frame(width: 35, height: 33)
                                        .foregroundColor(Color.accentColor)
                                    Text("대본추가")
                                        .foregroundColor(Color.accentColor)
                                }
                                .confirmationDialog("타이틀", isPresented: $isSheetShowing) {
                                    Button("대본 삭제", role: .destructive) {
                                        self.isShowingAlert = true
                                    }
                                    .alert(isPresented: $isShowingAlert) {
                                        Alert(title: Text("Alert Title"), message: Text("Alert Message"), dismissButton: .default(Text("OK")))}
                                    Button("대본 수정", role: .destructive) {
                                        
                                    }
                                    Button("취소", role: .cancel) {
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle("Pressor")
                .navigationBarItems(trailing: NavigationLink(destination: AddRecordScriptModalView()) {
                    Image(systemName: "gearshape.fill")})
                .foregroundColor(Color(red: 209/255, green: 209/255, blue: 214/255))
            }
            .tabItem {
                Image(systemName: "mic.circle.fill")
                Text("녹음")
            }
            
            InterviewListView()
                .tabItem {
                    Image(systemName: "doc.plaintext")
                    Text("인터뷰")
                }
        }
        .accentColor(.red)
        
        //        NavigationView {
        //            VStack {
        //                NavigationLink(destination: InterviewRecordingTestView(vm: vm)) {
        //                    Text("녹음 ㄱㄱ")
        //                        .bold()
        //                        .font(.system(size: 30))
        //                        .foregroundColor(Color.white)
        //                        .frame(width: 150, height: 80)
        //                        .background(RoundedRectangle(cornerRadius: 30)
        //                        .fill(Color.red))
        //                        .onAppear {
        //                            // 메인뷰에서 마이크를 탭하는 시점에서 Interview 인스턴스를 생성하도록 변경
        //                            let fileManager = FileManager.default
        //                            let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //
        //                            // TODO: > Flow?  directoryPath가 계속 새로 만들어져야함
        //                            // 인터뷰를 끝내고 저장한다면 해당디렉토리에 파일을 저장하게 냅둠
        //                            // 인터뷰를 끝내고 저장을 하지 않는다면 삭제함
        //                            let directoryPath = documentUrl.appendingPathComponent("dir")
        //
        //                            do {
        //                                try fileManager.removeItem(atPath: directoryPath.path)
        //                            } catch {
        //                                print("Can't delete")
        //                            }
        //
        //                            do {
        //                                if !fileManager.fileExists(atPath: directoryPath.path) {
        //                                    try fileManager.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: false, attributes: nil)
        //                                }
        //                            } catch {
        //                                print("create folder error. do something")
        //                            }
        //
        //                            vm.interviewPath = directoryPath
        //                            print(vm.interviewPath)
        //                        }
        //                }
        //            }
        //        }
        
        
    }
}

struct MainTestView_Previews: PreviewProvider {
    static var previews: some View {
        MainTestView(vm: VoiceViewModel())
    }
}
