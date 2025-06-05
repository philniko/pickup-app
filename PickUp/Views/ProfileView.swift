//
//  ProfileView.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Profile Image
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.gray)
                
                // User Info
                VStack(spacing: 8) {
                    if let user = authManager.currentUser {
                        Text(user.username)
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                Spacer()
                
                // Sign Out Button
                Button(action: signOut) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func signOut() {
        authManager.signOut()
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}
