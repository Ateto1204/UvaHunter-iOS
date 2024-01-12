import SwiftUI
import Foundation

struct ContentView: View {
    
    @State private var userName: String = ""
    @State private var userId: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var problems: [MyData] = []
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
                    let decodedData = try JSONDecoder().decode([MyData].self, from: data)
                    self.problems = decodedData
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

struct MyData {
    var values: [MyType]
}

extension MyData: Codable {
    init(from decoder: Decoder) throws {
        values = [MyType]()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let value = try container.decode(MyType.self)
            values.append(value)
        }
    }
}

enum MyType: Codable {
    case intType(Int)
    case stringType(String)
    
    init(from decoder: Decoder) throws {
        if let intType = try? decoder.singleValueContainer().decode(Int.self) {
            self = .intType(intType)
            return 
        } else if let stringType = try? decoder.singleValueContainer().decode(String.self) {
            self = .stringType(stringType)
            return 
        }
        
        throw DecodingError.typeMismatch(MyType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported Type..."))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .intType(let value): 
            try container.encode(value)
        case .stringType(let value): 
            try container.encode(value)
        }
    }
}
