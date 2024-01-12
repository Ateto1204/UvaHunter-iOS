import SwiftUI
import Foundation

struct ContentView: View {
    
    @State private var userName: String = ""
    @State private var userId: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var problems: MyData = MyData(values: [])
    @State private var name: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter the user name", text: $userName)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(6)
                    .padding()
                Button {
                    print(userName)
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
            
            Text(userId)
                .padding()
            ScrollView {
                
            }
        }
    }
    
    func getProblems(userId: String) {
        if let url = URL(string: "https://uhunt.onlinejudge.org/api/p/unsolved/\(userId)") {
            Task {
                do {
                    let (data, response) = try await URLSession.shared.data(from: url)
                    let decodeData = try JSONDecoder().decode(MyData.self, from: data)
                    self.problems = decodeData
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

struct MyData: Codable {
    let values: [[Any]]
    
    enum CodingKeys: String, CodingKey {
        case values
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        values = try container.decode([[Any]].self, forKey: .values)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(values, forKey: .values)
    }
}
