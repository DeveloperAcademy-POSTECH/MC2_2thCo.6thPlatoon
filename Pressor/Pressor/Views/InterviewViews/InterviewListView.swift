//
//  InterviewListView.swift
//  Pressor
//
//  Created by sup on 2023/05/03.
//

import SwiftUI

//MARK: - interview에서 해당 구조체가 넘어온다고 가정
// TODO: - 추후에 실제 데이터로 바꿔요
struct dummyDataa {
    let id = UUID().uuidString
    let title: String
    let date : Date!
    let interviewTime: String
}


struct InterviewListView: View {


    // 위의 Todo의 실제데이터가 들어올 내용이 items입니다.
    @State var items = [
        dummyDataa(title: "team1 interview Banana",
                   date:Calendar.current.date(from: DateComponents(year: 2021, month: 7, day: 1)),
                   interviewTime: "07:37") ,
        dummyDataa(title: "team2 interview Banana Melon",
                   date: Calendar.current.date(from: DateComponents(year: 2022, month: 7, day: 1)),
                   interviewTime: "32:37"),
        dummyDataa(title: "team3 interview Melon",
                   date: Calendar.current.date(from: DateComponents(year: 2023, month: 7, day: 1)),
                   interviewTime: "12:37")

    ]

    @State var selectedRows = Set<String>()

    @State var isEditing = false
    @State var showAlert = false

    @State var navigationTitleString = ""
    @State var searchText = ""

    var searchResults : [dummyDataa] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.title.contains(searchText) }
        }
    }
    
    var body: some View {


        NavigationView {

            VStack{
                List(selection: $selectedRows) {
                    ForEach(searchResults, id: \.id) {
                        one in
                        VStack(alignment: .leading) {
                            Text(one.title)
                                .font(.body)

                            Text(one.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .listRowBackground(Color(UIColor.systemGray6))
                        
                    }
                    
                    

                }
                // NavigationView 전체 색상 적용
                .scrollContentBackground(.hidden) // NavigationView Background적용을 위한 세팅
                .background(Color.white) // NavigationView 전체 색상
                .navigationTitle(isEditing ? "\(selectedRows.count)개가 선택됨" : "인터뷰")
                .navigationBarTitleDisplayMode(.inline)


                .toolbar {
                    if isEditing {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                isEditing.toggle()
                            } label: {
                                Text("취소")
                                    .foregroundColor(Color.red)
                            }

                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            
                            if !isEditing {
                                isEditing.toggle()
                            } else if isEditing  {
                                showAlert.toggle()
                            }


                        } label: {
                            Text(isEditing ? "삭제" : "편집" )
                                .foregroundColor(Color.red)
                        }
                        
                        

                    }


                }


                //편집 클릭시 멀티셀렉션 돌아가게 해주는 내용
                .environment(\.editMode, .constant(self.isEditing ? .active : .inactive))
                .animation(.default, value: isEditing)


                ForEach(items, id: \.id) {
                    one in
                    VStack(alignment: .leading) {
                        Text(one.title)
                            .font(.body)

                        Text(one.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)

                    }
                }
            }
            .searchable(text: $searchText, prompt: "Interview 검색")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("인터뷰 삭제"),
                      message: Text("\(selectedRows.count)개의 인터뷰가 삭제됩니다"),
                      primaryButton: .destructive(Text("삭제"),
                                                  action: {
                    delete()
                    isEditing.toggle()
                    
                } ) ,
                      secondaryButton: .cancel(Text("취소"))
                )
            }
            


        }



    }


    func swipeDelete(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
    
    func delete() {
        print("반복")
        for item in selectedRows {
            print(item)
            if let index = items.lastIndex(where: { $0.id == item }) {
                items.remove(at: index)
                
            }
        }

    }

}

struct InterviewListView_Previews: PreviewProvider {
    static var previews: some View {
        InterviewListView()
    }
}

