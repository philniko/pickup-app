//
//  AuthView.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    // For managing auth state
    @Binding var isAuthenticated: Bool
    @AppStorage("currentUserId") var currentUserId: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // App Logo/Title
            VStack(spacing: 8) {
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("PickUp")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Find your next game")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Login/Signup Toggle
            Picker("", selection: $isLoginMode) {
                Text("Login").tag(true)
                Text("Sign Up").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Input Fields
            VStack(spacing: 16) {
                if !isLoginMode {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !isLoginMode {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.horizontal)
            
            // Error Message
            if showError && !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            
            // Auth Button
            Button(action: handleAuth) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text(isLoginMode ? "Login" : "Sign Up")
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormValid ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(!isFormValid || isLoading)
            
            // Forgot Password (for login mode)
            if isLoginMode {
                Button(action: resetPassword) {
                    Text("Forgot Password?")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Terms and Privacy
            if !isLoginMode {
                Text("By signing up, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .animation(.easeInOut, value: isLoginMode)
    }
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty && isValidEmail(email)
        } else {
            return !email.isEmpty &&
                   !password.isEmpty &&
                   !username.isEmpty &&
                   password == confirmPassword &&
                   password.count >= 6 &&
                   isValidEmail(email) &&
                   username.count >= 3
        }
    }
    
    // MARK: - Functions
    
    func handleAuth() {
        hideKeyboard()
        showError = false
        errorMessage = ""
        isLoading = true
        
        if isLoginMode {
            signIn()
        } else {
            signUp()
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = getErrorMessage(error)
                showError = true
                return
            }
            
            if let user = result?.user {
                currentUserId = user.uid
                isAuthenticated = true
            }
        }
    }
    
    func signUp() {
        // First check if username is available
        let db = Firestore.firestore()
        let usernameQuery = db.collection("users").whereField("username", isEqualTo: username.lowercased())
        
        usernameQuery.getDocuments { snapshot, error in
            if let error = error {
                isLoading = false
                errorMessage = "Error checking username: \(error.localizedDescription)"
                showError = true
                return
            }
            
            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                isLoading = false
                errorMessage = "Username is already taken"
                showError = true
                return
            }
            
            // Username is available, proceed with sign up
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    isLoading = false
                    errorMessage = getErrorMessage(error)
                    showError = true
                    return
                }
                
                if let user = result?.user {
                    // Create user document in Firestore
                    let userData: [String: Any] = [
                        "id": user.uid,
                        "username": username,
                        "email": email,
                        "profileImageURL": NSNull()
                    ]
                    
                    db.collection("users").document(user.uid).setData(userData) { error in
                        isLoading = false
                        
                        if let error = error {
                            errorMessage = "Error creating user profile: \(error.localizedDescription)"
                            showError = true
                            // Consider deleting the auth user if profile creation fails
                            user.delete()
                            return
                        }
                        
                        currentUserId = user.uid
                        isAuthenticated = true
                    }
                }
            }
        }
    }
    
    func resetPassword() {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = getErrorMessage(error)
                showError = true
            } else {
                errorMessage = "Password reset email sent successfully"
                showError = true
            }
        }
    }
    
    func getErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered"
        case AuthErrorCode.weakPassword.rawValue:
            return "Password must be at least 6 characters"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password"
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email"
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection"
        default:
            return error.localizedDescription
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(isAuthenticated: .constant(false))
    }
}
