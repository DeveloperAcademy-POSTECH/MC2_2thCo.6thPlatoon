//
//  MainRecordView.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI

struct MainRecordView: View {
    
    @State var isSheetShowing: Bool = false
    @State var isShowingAlert = false
    @State var showModal = false
    @State var scriptAdded: Bool = false
    @State var count = 3
    @State var isShownInterviewRecordingView = false
    
    init() {
      UITabBar.appearance().scrollEdgeAppearance = .init()
    }
    
    var body: some View {
        
        TabView {
            NavigationView {
                VStack {
                    Text("새로운 인터뷰 녹음을 시작하려면\n아래 녹음 버튼을 눌러주세요.")
                        .font(.headline)
                        .foregroundColor(Color(red: 193/255, green: 193/255, blue: 200/255))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 50)
                    VStack {
                        Button {
                            self.isShownInterviewRecordingView.toggle()
                        } label: {
                            Image("mic_button")
                                .padding(.bottom, 40)
//                            VStack {
//                                ZStack {
//                                    Rectangle()
//                                        .frame(width: 216, height: 216)
//                                        .cornerRadius(88)
//                                        .foregroundColor(Color(red: 248/255, green: 248/255, blue: 249/255, opacity: 1))
//                                    Rectangle()
//                                        .frame(width: 182, height: 182)
//                                        .cornerRadius(70)
//                                        .foregroundColor(Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 1))
//                                        .shadow(color: Color.gray.opacity(0.4), radius: 30, x: 0, y: 0)
//                                    Rectangle()
//                                        .frame(width: 154, height: 154)
//                                        .cornerRadius(57)
//                                        .foregroundColor(Color.white)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 57)
//                                                .strokeBorder(Color.red, lineWidth: 3)
//                                        )
//                                    Image(systemName: "mic.fill")
//                                        .resizable()
//                                        .frame(width: 38, height: 60)
//                                        .foregroundColor(Color.red)
//                                }
//                                .padding(.bottom, 67)
//                            }
                        }
                        .fullScreenCover(isPresented: $isShownInterviewRecordingView) {
                            InterviewRecordingView()
                        }
                    }
                    VStack {
                        Button(action: {
                            if scriptAdded {
                                self.isSheetShowing = true
                                scriptAdded = true
                            } else {
                                showModal.toggle()
                                scriptAdded = false
                            }
                        }) {
                            VStack {
                                if scriptAdded {
                                    VStack{
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
                                            Alert(title: Text("Alert Title"), message: Text("Alert Message"), dismissButton: .default(Text("OK")))}
                                        Button("대본 수정", role: .destructive) {
                                            
                                        }
                                        Button("취소", role: .cancel) {
                                            
                                        }
                                    }
                                } else {
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
                .navigationBarItems(trailing: NavigationLink(destination: AddRecordScriptModalView()) {
                    Image(systemName: "gearshape.fill")})
                .foregroundColor(Color(red: 209/255, green: 209/255, blue: 218/255))
                .sheet(isPresented: $showModal) {
                    AddScriptModalView(scriptAdded: $scriptAdded)
                }
            }
            .tabItem {
                Image(systemName: "mic.circle.fill")
                Text("녹음")
            }
            
            InterviewListView()
                .tabItem {
                    Image(systemName: "mic.circle.fill")
                    Text("녹음")
                }
        }
        
        .accentColor(.red)
    }
}

struct MainRecordView_Previews: PreviewProvider {
    static var previews: some View {
        MainRecordView()
    }
}
