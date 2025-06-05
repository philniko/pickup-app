//
//  PickUpApp.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@main
struct PickUpApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}

// MARK: - Auth Manager

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var userListener: ListenerRegistration?
    
    init() {
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let user = user {
                    // Fetch user data from Firestore
                    self?.fetchUserData(userId: user.uid)
                } else {
                    self?.currentUser = nil
                    self?.userListener?.remove()
                    self?.userListener = nil
                }
            }
        }
    }
    
    private func fetchUserData(userId: String) {
        let db = Firestore.firestore()
        
        // Remove existing listener if any
        userListener?.remove()
        
        // Set up real-time listener for user document
        userListener = db.collection("users").document(userId).addSnapshotListener { [weak self] document, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists, let data = document.data() {
                // Manually create User object from Firestore data
                self?.currentUser = User(
                    id: document.documentID,
                    username: data["username"] as? String ?? "User",
                    email: data["email"] as? String ?? Auth.auth().currentUser?.email ?? "",
                    profileImageURL: data["profileImageURL"] as? String
                )
            } else {
                // User document doesn't exist, create basic user
                self?.currentUser = User(
                    id: userId,
                    username: "User",
                    email: Auth.auth().currentUser?.email ?? "",
                    profileImageURL: nil
                )
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func refreshUserData() {
        if let userId = Auth.auth().currentUser?.uid {
            fetchUserData(userId: userId)
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        userListener?.remove()
    }
}
