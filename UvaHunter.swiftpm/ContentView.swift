import SwiftUI
import Foundation
import Network

struct ContentView: View {
    
    @ObservedObject private var networkManager: NetworkManager = NetworkManager()
    
    @State private var userName: String = ""
    @State private var userInput: String = ""
    @State private var userId: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var problems: [Item] = []
    @State private var hasResponsed: Bool = true
    @State private var picked: [Int] = []
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if networkManager.isNetworkAvailable {
                    ZStack {
                        VStack(spacing: 0) {
                            HStack {
                                TextField("Enter the user name", text: $userName)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(6)
                                    .padding()
                                Button {
                                    if hasResponsed {
                                        if userName.isEmpty {
                                            self.showAlert = true
                                        } else {
                                            self.hasResponsed = false
                                            self.userId = ""
                                            getUserId(userName: userName)
                                            self.userName = ""
//                                            getProblems(userId: userId)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "location.circle")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(self.hasResponsed ? .accentColor : .secondary)
                                        .frame(width: 36, height: 36)
                                        .padding(.trailing, 20)
                                }
                                .alert("Your username can not be empty.", isPresented: $showAlert) {
                                    Button("OK") {
                                        showAlert = false
                                    }
                                }
                            }
                            .padding(.top, 15)
                            
                            HStack {
                                TextField(userId.isEmpty ? "Enter the user ID" : "user ID: \(userId)", text: $userInput)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(6)
                                    .padding()
                                Button {
                                    if hasResponsed {
                                        if userInput.isEmpty {
                                            self.showAlert = true
                                        } else {
                                            self.hasResponsed = false
                                            self.userId = userInput
                                            getProblems(userId: userId)
                                            self.userInput = ""
                                        }
                                    }
                                } label: {
                                    Image(systemName: "location.circle")
                                        .resizable()
                                        .scaledToFill()
                                        .foregroundColor(self.hasResponsed ? .accentColor : .secondary)
                                        .frame(width: 36, height: 36)
                                        .padding(.trailing, 20)
                                }
                                .alert("Your user ID can not be empty.", isPresented: $showAlert) {
                                    Button("OK") {
                                        showAlert = false
                                    }
                                }
                            }
                            if hasResponsed && userId == "640140" || userId == "0"{
                                ContentUnavailableView("Username does not exist", systemImage: "exclamationmark.triangle.fill")
                            } else if hasResponsed {
                                ScrollView {
                                    VStack(alignment: .leading) {
                                        if hasResponsed && problems.count > 5 {
                                            HStack {
                                                Spacer()
                                                VStack(alignment: .leading, spacing: 0) {
                                                    ForEach(0..<5) { i in 
                                                        HStack {
                                                            Group {
                                                                if !picked.isEmpty && picked.count >= 5 && problems.count > picked[i] {
                                                                    Link(destination: URL(string:  "https://domen111.github.io/UVa-Easy-Viewer/?\(problems[picked[i]].number)")!, label: {
                                                                        Text("Link")
                                                                    })
                                                                    Text("\(problems[picked[i]].number)")
                                                                    Text("\(problems[picked[i]].letter)")
                                                                }
                                                            }
                                                            .padding()
                                                        }
                                                        .onAppear(perform: {
                                                            self.problems.remove(at: picked[i])
                                                        })
                                                    }
                                                }
                                                Spacer()
                                            }
                                            
                                            Button {
                                                getPicked()
                                            } label: {
                                                HStack {
                                                    Spacer()
                                                    Text("Refresh")
                                                        .foregroundColor(.white)
                                                        .padding()
                                                        .background(Color.accentColor)
                                                        .cornerRadius(12)
                                                        .padding()
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                Spacer()
                            }
                        }
                        .refreshable {
                            await getPicked()
                        }
                        
                        if !hasResponsed {
                            ProgressView()
                                .padding()
                        }
                    }
                } else {
                    ContentUnavailableView("No Internet Connect", systemImage: "wifi.slash")
                }
            }
            .navigationTitle("UVa Hunter")
        }
    }
    
    func getPicked() {
        picked.removeAll()
        for _ in 1...5 {
            let p: Int = .random(in: 0...problems.endIndex)
            picked.append(p)
        }
    }
    
    func getProblems(userId: String) {
        print("get problem userid: \(userId)")
        if let url = URL(string: "https://uhunt.onlinejudge.org/api/p/unsolved/\(userId)") {
            Task {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    let decodedData = try JSONDecoder().decode([Item].self, from: data)
                    self.problems = decodedData
                    getPicked()
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
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    if let id = String(data: data, encoding: .utf8) {
                        //                    DispatchQueue.main.sync {
                        self.userId = id
                        getProblems(userId: userId)
                        //                    }
                    }
                } catch {
                    print(error)
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

class NetworkManager: ObservableObject {
    let monitor = NWPathMonitor()
    @Published var isNetworkAvailable: Bool = false
    
    init() {
        monitor.pathUpdateHandler = { path in 
            self.isNetworkAvailable = path.status == .satisfied
        }
        monitor.start(queue: DispatchQueue.global())
    }
}
