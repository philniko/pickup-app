//
//  AuthView.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import SwiftUI

struct AuthView: View {
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            Picker("", selection: $isLoginMode) {
                Text("Login").tag(true)
                Text("Sign Up").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
             SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: handleAuth) {
                Text(isLoginMode ? "Login" : "Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    func handleAuth() {
        // implement firebase auth here
    }
}

#Preview {
    AuthView()
}
