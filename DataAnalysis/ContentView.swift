//
//  ContentView.swift
//  DataAnalysis
//
//  Created by Conner Yoon on 3/14/25.
//

import SwiftUI
struct Response: Identifiable {
    var id = UUID()
    var answerText: String = ""
    var count = 0
}
struct ContentView: View {
    @State var col : Int = 1
    @State var answerData : [Answer] = []
    @State private var isLoading = false
    @State private var responses: [Response] = []
    func getQuestion()->String{
        var name =  "No name provided"
        switch col {
        case 1:
            name = "What is your age ?"
        case 2:
            name = "Among the following reasons why do you like to play video games ?"//Kinda mult
        case 3:
            name = "What are your 3 favorite game genres ?"//Mult
        case 4:
            name = "From the genres you have selected in the previous question what are your favorite titles ?"//Free response
        case 5:
            name = "On which platforms do you play games from your favorite genres the most ?"//Mult
        case 6:
            name = "On average, when you commit to a game from your favorite genres, how often do you play it ?"
        case 7:
            name = "On average, when you play games from your favorite genres, how long do your sessions last ?"
        case 8:
            name = "Among the following sentences, which ones are the most representative of your way of playing games from your favorite genres ?"//Mult
        case 9:
            name = "It feels more rewarding to play fairly even if the game is difficult and / or long"//Mult
        case 10:
            name = "How do you like to discover new games to play ?"
            //Mult
        case 11:
            name = "Through which types of content do you like learning more about new games ?"//Mult
        case 12:
            name = "What features are decisive to you when choosing one game over another ?"//Mult
        default:
           _ = 1
        }
        return name
    }
    private func change() async{
        await getData()
        getUniqueResponses()
        responses.sort {
            $0.count > $1.count
        }
    }
    @State var searchText : String = ""
    var body: some View {
        NavigationStack {
            VStack {
                Stepper("Column \(col)", onIncrement: {
                    Task{
                        if col < 12 && isLoading == false {//Kind of magic number
                            col+=1
                            responses = []
                            await change()
                        }
                    }
                }, onDecrement: {
                    Task{
                        if col > 1 && isLoading == false {
                            col-=1
                            responses = []
                            await change()
                        }
                    }
                })
                Text(getQuestion())
                ZStack{
                    if isLoading {
                        ProgressView()
                    }
                }
                
                
                List{
                    ForEach(searchText.isEmpty ? responses : responses.filter{ $0.answerText.localizedStandardContains(searchText)}) { response in
                        HStack {
                            Text("\(response.count) ")
                                .frame(width: 100)
                            Text("\(response.answerText)")
                        }.textSelection(.enabled)
                            .padding()
                    }
                }
                .searchable(text: $searchText)
                .listStyle(.plain)
            }.task {
                await getData()
                getUniqueResponses()
                responses.sort {
                    $0.count > $1.count
                }
            }
            .padding()
        }
    }
    
    func getUniqueResponses() {
        for answer in answerData {
            if !isInResponses(answer) {
                responses.append(Response(answerText: answer.text))
            }
            incrementResponseCount(with: answer)
        }
    }
    func incrementResponseCount(with answer: Answer) {
        guard let index = responses.firstIndex(where: {$0.answerText == answer.text}) else { return }
        responses[index].count += 1
    }
    func isInResponses(_ answer: Answer) -> Bool {
        for response in responses {
            if answer.text == response.answerText {
                return true
            }
        }
        return false
    }
    
    func getData() async {
        do {
            isLoading = true
            answerData = try await CSVManager.getDataFrom(fileName: "Column \(col)")
            isLoading = false
        }catch{
            print("\(error)")
        }
    }
}

#Preview {
    ContentView()
}
