import SwiftUI
import Foundation

struct ContentView: View {
    
    @State private var userName: String = ""
    @State private var userId: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var problems: String = ""
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
            Text(problems)
//            ScrollView {
//                ForEach(problems.indices) { idx in 
//                    Text(problems[idx])
//                }
//            }
        }
    }
    
    func getProblems(userId: String) {
        guard let url = URL(string: "https://uhunt.onlinejudge.org/api/p/unsolved/\(userId)") else {
            return 
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in 
            if let error = error {
                print(error)
            } else if let data = data {
                if let problems = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.sync {
                        self.problems = problems
                    }
                }
            }
        }.resume()
    }
    
    func getUserId(userName: String) {
        guard let url = URL(string: "https://uhunt.onlinejudge.org/api/uname2uid/\(userName)") else {
            return 
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in 
            if let error = error {
                print(error)
            } else if let data = data {
                if let id = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.sync {
                        self.userId = id
                    }
                }
            }
        }.resume()
    }
    
}
