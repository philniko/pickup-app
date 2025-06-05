//
//  EventListView.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct EventListView: View {
    @State private var events: [Event] = []
    @State private var isLoading = true
    @State private var selectedFilter: EventFilter = .all
    @State private var searchText = ""
    
    enum EventFilter: String, CaseIterable {
        case all = "All"
        case joined = "Joined"
        case created = "Created"
        case upcoming = "Upcoming"
    }
    
    var filteredEvents: [Event] {
        let filtered = events.filter { event in
            switch selectedFilter {
            case .all:
                return true
            case .joined:
                return event.currentParticipants.contains(Auth.auth().currentUser?.uid ?? "")
            case .created:
                return event.creatorId == Auth.auth().currentUser?.uid
            case .upcoming:
                return event.date > Date()
            }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.sportType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                event.location.venueName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search events...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(EventFilter.allCases, id: \.self) { filter in
                            FilterPill(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter,
                                action: { selectedFilter = filter }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                // Events List
                if isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                    Spacer()
                } else if filteredEvents.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No events found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try adjusting your filters or check back later")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredEvents) { event in
                                EventCard(event: event)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                fetchEvents()
            }
        }
    }
    
    func fetchEvents() {
        // Fetch from Firestore
        let db = Firestore.firestore()
        db.collection("events")
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                isLoading = false
                
                if let error = error {
                    print("Error fetching events: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.events = documents.compactMap { doc in
                    let data = doc.data()
                    
                    // Parse date
                    let date: Date
                    if let timestamp = data["date"] as? Timestamp {
                        date = timestamp.dateValue()
                    } else {
                        date = Date()
                    }
                    
                    // Parse location
                    let locationData = data["location"] as? [String: Any] ?? [:]
                    let location = Location(
                        latitude: locationData["latitude"] as? Double ?? 0,
                        longitude: locationData["longitude"] as? Double ?? 0,
                        address: locationData["address"] as? String ?? "",
                        venueName: locationData["venueName"] as? String
                    )
                    
                    // Parse sport type
                    let sportTypeString = data["sportType"] as? String ?? ""
                    let sportType = SportType(rawValue: sportTypeString) ?? .basketball
                    
                    return Event(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        sportType: sportType,
                        location: location,
                        date: date,
                        maxParticipants: data["maxParticipants"] as? Int ?? 0,
                        currentParticipants: data["currentParticipants"] as? [String] ?? [],
                        creatorId: data["creatorId"] as? String ?? ""
                    )
                }
            }
    }
}

// MARK: - Supporting Views

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct EventCard: View {
    let event: Event
    @State private var isJoined = false
    
    var participantCount: String {
        "\(event.currentParticipants.count)/\(event.maxParticipants)"
    }
    
    var isFull: Bool {
        event.currentParticipants.count >= event.maxParticipants
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                // Sport Icon
                Image(systemName: getSportIcon(event.sportType))
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(getSportColor(event.sportType))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                    
                    HStack {
                        Label(event.sportType.rawValue, systemImage: "sportscourt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label(participantCount, systemImage: "person.2")
                            .font(.caption)
                            .foregroundColor(isFull ? .red : .secondary)
                    }
                }
                
                Spacer()
            }
            
            // Date & Location
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text(formatDate(event.date))
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }
                
                Label {
                    Text(event.location.venueName ?? event.location.address)
                        .font(.subheadline)
                        .lineLimit(1)
                } icon: {
                    Image(systemName: "location")
                        .foregroundColor(.blue)
                }
            }
            
            // Description
            if !event.description.isEmpty {
                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Join Button
            Button(action: toggleJoin) {
                Text(isJoined ? "Leave" : "Join")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isJoined ? .red : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isJoined ? Color.red.opacity(0.1) : (isFull && !isJoined ? Color.gray : Color.blue))
                    .cornerRadius(8)
            }
            .disabled(isFull && !isJoined)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onAppear {
            checkIfJoined()
        }
    }
    
    func toggleJoin() {
        // Implement join/leave functionality
        isJoined.toggle()
    }
    
    func checkIfJoined() {
        if let userId = Auth.auth().currentUser?.uid {
            isJoined = event.currentParticipants.contains(userId)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d • h:mm a"
        return formatter.string(from: date)
    }
    
    func getSportIcon(_ sport: SportType) -> String {
        switch sport {
        case .basketball:
            return "basketball"
        case .soccer:
            return "soccerball"
        case .tennis:
            return "tennisball"
        case .volleyball:
            return "volleyball"
        case .hiking:
            return "figure.hiking"
        }
    }
    
    func getSportColor(_ sport: SportType) -> Color {
        switch sport {
        case .basketball:
            return .orange
        case .soccer:
            return .green
        case .tennis:
            return .yellow
        case .volleyball:
            return .blue
        case .hiking:
            return .brown
        }
    }
}

// MARK: - Preview

#Preview {
    EventListView()
}
