//
//  ContentView.swift
//  BurpeeCounter
//
//  Created by Santosh Borse on 3/12/21.
//

import SwiftUI
import Foundation

struct BSummary: Codable {
    var count: Int
}

struct ContentView: View {
    @State var count: Int
    @State var lastCount: Int = 0
    
    
    func postCount(postCount: Int) {
        guard let url = URL(string: "http://localhost:8080/api/v1/count") else {
                    fatalError()
                }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let bSummary = BSummary(count: postCount)
        let jsonData = try! JSONEncoder().encode(bSummary)
        print(jsonData)
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error \(error)")
                return
            }
            guard let data = data else {return}
            print(data)
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                if(httpResponse.statusCode == 200) {
                    lastCount = postCount
                }
            }
            
        }.resume()
    }
    
    func loadData() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if(count == lastCount) {
                print("No change in count, no need to save")
                return
            }
            print("Posting Updated Count: \(count) from original Count: \(lastCount)")
            postCount(postCount: count)
        }
        
        guard let url = URL(string: "http://localhost:8080/api/v1/count") else {
                    print("Invalid URL")
                    return
                }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try? JSONDecoder().decode(BSummary.self, from: data) {
                    DispatchQueue.main.async {
                        self.count = response.count
                        self.lastCount = response.count
                    }
                    print(response)
                    return
                }
            }            
        }.resume()
    }
    
    var body: some View {
        
        VStack {
            Text("Burpees Counter")
                .bold()
                .padding()
            Button(action: {
                print("Increase Counter")
                self.count += 1
            }, label: {
                Text("\(self.count)")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(60)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .font(.system(size: 80))
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    .shadow(color: .orange, radius: 100)
                    
            })
            
            
            Text("* Click on circle to increase count")
                .font(.system(size: 10))
                .foregroundColor(.blue)
        }
        .onAppear(perform: {
            print("ON Appear called")
            loadData()
        })
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(count: 13)
    }
}
