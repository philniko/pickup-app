//
//  MapView.swift
//  PickUp
//
//  Created by Philippe Nikolov on 2025-06-04.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    // Mock events
    let events: [Event] = [
        Event(
            id: "1",
            title: "Basketball Pickup",
            description: "Casual 3v3",
            sportType: .basketball,
            location: Location(
                latitude: 37.7749,
                longitude: -122.4194,
                address: "123 Court St",
                venueName: "Golden Gate Park"
            ),
            date: Date(),
            maxParticipants: 6,
            currentParticipants: ["user1", "user2"],
            creatorId: "user1"
        )
    ]
    
    var body: some View {
        Map(position: $position) {
            ForEach(events) { event in
                Annotation(event.title, coordinate: CLLocationCoordinate2D(
                    latitude: event.location.latitude,
                    longitude: event.location.longitude
                )) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                        .font(.title)
                }
            }
            
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    MapView()
}
