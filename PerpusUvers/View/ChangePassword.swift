//
//  ChangePassword.swift
//  PerpusUvers
//
//  Created by Erwin on 04/04/24.
//

import SwiftUI

struct ChangePassword: View {
    @State private var password: String = ""
    @State private var confirmedPassword: String = ""
    @State private var isError: Bool = false
    @State private var isLoading: Bool = false
    @State private var user: UserData? = nil
    var body: some View {
        VStack{
            HStack{
                Text("New Password").padding()
                TextField("Enter New Password", text: $password).padding()
            }.padding(.horizontal, 30)
            HStack{
                Text("Confirm Password").padding()
                SecureField("Confirm New Password", text: $confirmedPassword).padding()
            }.padding(.horizontal, 30)
            if isError {
                Text("Username or password is wrong")
                    .foregroundStyle(Color.red)
            }
            Spacer()
            if !isLoading {
                Button(action: { changePassword() }){
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
    
    func changePassword() {
        
    }
}
