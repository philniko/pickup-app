//
//  ContentView.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 1
    
    var body: some View {
        if authManager.isAuthenticated {
            MainTabView(selectedTab: $selectedTab)
                .environmentObject(authManager)
        } else {
            AuthView(isAuthenticated: $authManager.isAuthenticated)
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            EventListView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
                .tag(0)
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(1)
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.3.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .environmentObject(authManager)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
