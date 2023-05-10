//  InterviewViewModel.swift
//  Pressor
//
//  Created by Ha Jong Myeong on 2023/05/05.
//

import Foundation

class InterviewViewModel: ObservableObject {
    // 인터뷰 목록
    @Published var interviewScriptModel: InterviewScriptModel
    
    // Default initializer
    init() {
        self.interviewScriptModel = InterviewScriptModel(interviewScript: [])
    }
    
    // 대본 생성
    func createScript(title: String, content: String) {
        // 대본 추가
        interviewScriptModel.interviewScript.append((title: title, content: content))
    }
    
    // 대본 읽기
    func getScripts() -> [(title: String, content: String)] {
        // 대본 목록 반환
        return interviewScriptModel.interviewScript
    }
    
    // 대본 수정
    func updateScript(title: String, content: String, atIndex index: Int) {
        // 대본 수정
        interviewScriptModel.interviewScript[index] = (title: title, content: content)
    }
    
    // 대본 삭제
    func deleteScript(atIndex index: Int) {
        // 대본 삭제
        interviewScriptModel.interviewScript.remove(at: index)
    }
}
