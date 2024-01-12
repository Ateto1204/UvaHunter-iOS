import SwiftUI
import Foundation

struct ContentView: View {
    
    @State private var userId: String = ""
    @State private var isButtonPressed: Bool = false
    @State private var problems: [Int] = []
    @State private var name: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter the user id", text: $userId)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(6)
                    .padding()
                Button {
                    self.isButtonPressed = true
                    getUserName(forUserId: userId) { userName in 
                        if let userName = userName {
                            self.name = userName
                        } else {
                            self.name = "null"
                        }
                        
                    }
//                    self.problems = getUnsolveProblem(forUserId: userId)
                } label: {
                    Image(systemName: "location.circle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .padding(.trailing, 20)
                }
            }
            
            Text(name)
            
//            if problems.count > 0 {
//                List {
//                    ForEach(problems.indices) { idx in 
//                        Text("\(idx): \(problems[idx])")
//                    }
//                }
//            }
        }
    }
    
    func getUnsolveProblem(forUserId userId: String) -> [Int] {
        let url = URL(string: "https://uhunt.onlinejudge.org/api/p/unsolved/\(userId)")!
        var result: [Int] = []
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in 
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                do {
                    print("B")
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("A")
                        
                        if let problems = jsonResponse["problems"] as? [[String: Any]] {
                            let unsolvedProblems = problems.prefix(5)
                            for problem in unsolvedProblems {
                                if let problemId = problem["pnum"] as? Int {
                                    result.append(problemId)
                                }
                            }
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }
        print("\(result.count)")
        task.progress.resume()
        
        return result
    }
    
    func getUserName(forUserId userId: String, completion: @escaping (String?) -> Void) {
        let apiUrl = "http://uhunt.onlinejudge.org/api/uname2uid/"
        let url = URL(string: "\(apiUrl)\(userId)")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
            } else if let data = data {
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let userName = jsonResponse["username"] as? String {
                            completion(userName)
                        } else {
                            print("Invalid JSON format: Missing 'username' key")
                            completion(nil)
                        }
                    } else {
                        print("Failed to parse JSON")
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    
}
