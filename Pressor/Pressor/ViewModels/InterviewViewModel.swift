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
        self.interviewScriptModel = InterviewScriptModel(interviewScripts: [])
    }
    
    // 대본 생성
    func createScript(title: String, content: String) {
        // 대본 추가
        interviewScriptModel.interviewScripts.append(Script(scriptTitle: title, scriptContent: content))
    }
    
    // 대본 읽기
    func getScripts() -> [Script] {
        // 대본 목록 반환
        return interviewScriptModel.interviewScripts
    }
    
    // 대본 수정
    func updateScript(title: String, content: String, atIndex index: Int) {
        // 대본 수정
        interviewScriptModel.interviewScripts[index] = Script(scriptTitle: title, scriptContent: content)
    }
    
    // 대본 삭제
    func deleteScript(atIndex index: Int) {
        // 대본 삭제
        interviewScriptModel.interviewScripts.remove(at: index)
    }
}
