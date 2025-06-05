//
//  FriendsView.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import SwiftUI

struct FriendsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Friends feature coming soon!")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Text("Connect with friends and see their activities")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Preview

#Preview {
    FriendsView()
}
