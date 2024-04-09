//
//  LoginView.swift
//  PerpusUvers
//
//  Created by Erwin on 04/04/24.
//

import SwiftUI

struct LoginView:View {
    let userDefault = UserDefaults.standard
    let onLogin: () -> Void
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isError: Bool = false
    @State private var isLoading: Bool = false
    @State private var user: UserData? = nil
    var body: some View {
        VStack{
            Text("Welcome")
                .font(.title)
                .padding([.top, .bottom], 50)
                .shadow(radius: 6, x:10, y:10)
            TextField("Username", text: $username)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled(true)
                .clipShape(Capsule())
                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/, x:5, y:1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 30)
            SecureField("Password", text: $password)
                .clipShape(Capsule())
                .shadow(radius: 10, x:5, y:1)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(30)
            if isError {
                Text("Username or password is wrong")
                    .foregroundStyle(Color.red)
            }
            
            if !isLoading {
                Button(action: { login() }){
                    Text("Login")
                        .font(.headline)
                        .frame(width: 200, height: 60)
                        .background(Color.blue)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 10, x: 20, y: 10)
                        .padding(.top, 50)
                }
            } else {
                Button(action: {}){
                    Text("Loading...")
                        .font(.headline)
                        .frame(width: 200, height: 60)
                        .background(Color.green)
                        .foregroundStyle(Color.white)
                        .shadow(radius: 10, x: 20, y: 10)
                        .padding(.top, 50)
                }
            }
        }
    }
    
    func login(){
        hideKeyboard()
        isLoading = true
        fetchUserData()
    }
    
    func fetchUserData() {
        guard let url = URL(string: "http://lib.uvers.ac.id/api/user/login?username=\(username)&password=\(password)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let user = try JSONDecoder().decode(UserModel.self, from: data)
                DispatchQueue.main.async {
                    self.user = user.data
                    userDefault.set(user.data.access_token, forKey: "user_token")
                    onLogin()
                }
            } catch {
                isError = true
                isLoading = false
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func hideKeyboard(){
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
