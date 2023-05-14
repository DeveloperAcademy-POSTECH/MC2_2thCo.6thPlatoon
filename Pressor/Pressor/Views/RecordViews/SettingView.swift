//
//  SettingView.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/14.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.presentationMode) private var presentationMode  // 프레젠테이션 모드에 접근하기 위한 변수
    @Binding var isShown: Bool
    
    var body: some View {
        NavigationView{
            VStack{
                Spacer(minLength: 40)
                Image("app_icon")  // 앱 아이콘 이미지
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                Text("Pressor").fontWeight(.bold).font(.title3)
                // 앱 버전 정보
                Text("버전 : 0.1.1").font(.caption).opacity(0.5)
                Form{
                    Section{
                        NavigationLink(destination: Text("업데이트 내역")) {
                            Text("업데이트 내역").font(.body)
                        }
                        NavigationLink(destination: Text("개인정보처리방침")) {
                            Text("개인정보처리방침").font(.body)
                        }
                        NavigationLink(destination: Text("이용약관")) {
                            Text("이용약관").font(.body)
                        }
                        NavigationLink(destination: Text("오픈소스 라이센스")) {
                            Text("오픈소스 라이센스").font(.body)
                        }
                        NavigationLink(destination: Text("만든 사람들")) {
                            Text("만든 사람들").font(.body)
                        }
                    }.listRowBackground(Color(UIColor.systemGroupedBackground))
                }
                .scrollContentBackground(.hidden)
                .background(Color.white)
                Text("Pressor 및 Pressor 로고는 Apple Developer Academy @ POSTECH 및 팀 2중대 6소대 소유이며 프로그램 전체 또는 일부를 무단 복제 및 배포시 민형사상 처벌을 받을 수 있습니다.")
                    .padding(.horizontal, 16)
                    .opacity(0.5).font(.caption)  // 저작권 정보
                Spacer(minLength: 100)
            }
            .navigationBarTitle("정보", displayMode: .inline)
            .navigationBarItems(leading: backButton)
        }
        .navigationBarBackButtonHidden(true)
    }
    // 뒤로가기 버튼
    private var backButton: some View {
        Button(action: {  // "뒤로" 텍스트 버튼
            isShown = false // 버튼 클릭 시 현재 뷰 닫기
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                    .aspectRatio(contentMode: .fit)
                Text("뒤로")
            }
        }
        .foregroundColor(.PressorOrange)  // 버튼 색상 설정
    }
}
//
//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView()
//    }
//}
