//
//  StartTestView.swift
//  Pressor
//
//  Created by 홍승완 on 2023/05/03.
//

import SwiftUI

struct MainTestView: View {
    @ObservedObject var vm: VoiceViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: InterviewRecordingTestView(vm: vm)) {
                    Text("녹음 ㄱㄱ")
                        .bold()
                        .font(.system(size: 30))
                        .foregroundColor(Color.white)
                        .frame(width: 150, height: 80)
                        .background(RoundedRectangle(cornerRadius: 30)
                        .fill(Color.red))
                        .onAppear {
                            let fileManager = FileManager.default
                            let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]

                            // TODO: > Flow?  directoryPath가 계속 새로 만들어져야함
                            // 인터뷰를 끝내고 저장한다면 해당디렉토리에 파일을 저장하게 냅둠
                            // 인터뷰를 끝내고 저장을 하지 않는다면 삭제함
                            let directoryPath = documentUrl.appendingPathComponent("dir")
                            
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
                        }
                }
            }
        }
    }
}

//struct StartTestView_Previews: PreviewProvider {
//    static var previews: some View {
////        StartTestView()
//    }
//}
