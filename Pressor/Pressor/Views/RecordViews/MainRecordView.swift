//
//  MainRecordView.swift
//  Pressor
//
//  Created by Celan on 2023/05/02.
//

import SwiftUI

struct MainRecordView: View {
    
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
                            InterviewRecordingView()
                        }
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
    }
    
    struct MainRecordView_Previews: PreviewProvider {
        static var previews: some View {
            MainRecordView()
        }
    }
}
