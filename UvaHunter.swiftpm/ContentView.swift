import SwiftUI
import Foundation

struct ContentView: View {
    
    @State private var userName: String = ""
    @State private var userId: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var problems: [Item] = []
    @State private var name: String = ""
    @State private var hasResponsed: Bool = true
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TextField("Enter the user name", text: $userName)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(6)
                        .padding()
                    Button {
                        self.hasResponsed = false
                        getUserId(userName: userName)
                        getProblems(userId: userId)
                    } label: {
                        Image(systemName: "location.circle")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .padding(.trailing, 20)
                    }
                }
                
                Text("ID: \(userId)")
                    .padding()
                ScrollView {
                    VStack(alignment: .leading) {
                        if problems.count > 5 {
                            ForEach(0..<5) { i in 
                                let picked: Int = .random(in: 0...problems.endIndex)
                                HStack {
                                    Group {
                                        Link(destination: URL(string:  "https://domen111.github.io/UVa-Easy-Viewer/?\(problems[picked].number)")!, label: {
                                            Text("Link")
                                        })
                                        Text("\(problems[picked].number)")
                                        Text("\(problems[picked].letter)")
                                    }
                                    .padding()
                                }
                                .onAppear(perform: {
                                    self.problems.remove(at: picked)
                                })
                            }
                        }
                    }
                }
            }
            if !hasResponsed {
                ProgressView()
                    .padding()
            }
        }
    }
    
    func getProblems(userId: String) {
        if let url = URL(string: "https://uhunt.onlinejudge.org/api/p/unsolved/\(userId)") {
            Task {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    let decodedData = try JSONDecoder().decode([Item].self, from: data)
                    self.problems = decodedData
                    self.hasResponsed = true
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func getUserId(userName: String) {
        if let url = URL(string: "https://uhunt.onlinejudge.org/api/uname2uid/\(userName)") {
            Task {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let id = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.sync {
                        self.userId = id
                    }
                }
            }
        }
    }
    
}

struct Item {
    let number: Int
    let letter: String
}

extension Item: Codable {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let _ = try container.decode(Int.self)
        let number = try container.decode(Int.self)
        let letter = try container.decode(String.self)
        
        self.init(number: number, letter: letter)
    }
}
