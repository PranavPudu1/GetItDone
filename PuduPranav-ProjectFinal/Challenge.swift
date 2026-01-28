// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E
import Foundation
import FirebaseFirestore

struct Challenge {
    let id: String
    let name: String
    let durationDays: Int
    let type: String
    let description: String
    let stakeAmount: Int
    let locationName: String?
    let locationLatitude: Double?
    let locationLongitude: Double?
    let creatorUID: String
    let participants: [String]
    let invitedFriends: [String]
    let status: String
    let isPublic: Bool
    let createdAt: Date
    let startDate: Date
    let endDate: Date

    // Initialize from Firestore document
    init(id: String, data: [String: Any]) {
        self.id = id
        self.name = data["name"] as? String ?? ""
        self.durationDays = data["durationDays"] as? Int ?? 0
        self.type = data["type"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
        self.stakeAmount = data["stakeAmount"] as? Int ?? 0
        self.locationName = data["location"] as? String
        self.locationLatitude = data["locationLatitude"] as? Double
        self.locationLongitude = data["locationLongitude"] as? Double
        self.creatorUID = data["creatorId"] as? String ?? ""
        self.participants = data["participants"] as? [String] ?? []
        self.invitedFriends = data["invitedFriends"] as? [String] ?? []
        self.status = data["status"] as? String ?? "active"
        self.isPublic = data["isPublic"] as? Bool ?? false

        // Handle Firestore timestamps
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }

        if let timestamp = data["startDate"] as? Timestamp {
            self.startDate = timestamp.dateValue()
        } else {
            self.startDate = Date()
        }

        if let timestamp = data["endDate"] as? Timestamp {
            self.endDate = timestamp.dateValue()
        } else {
            self.endDate = Date()
        }
    }

    // Initialize with parameters (for creating new challenges)
    init(
        name: String,
        durationDays: Int,
        type: String,
        description: String,
        stakeAmount: Int,
        locationName: String?,
        locationLatitude: Double?,
        locationLongitude: Double?,
        creatorUID: String,
        invitedFriends: [String],
        isPublic: Bool = false
    ) {
        self.id = "" // Will be set by Firestore
        self.name = name
        self.durationDays = durationDays
        self.type = type
        self.description = description
        self.stakeAmount = stakeAmount
        self.locationName = locationName
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.creatorUID = creatorUID
        self.participants = [creatorUID]
        self.invitedFriends = invitedFriends
        self.status = "active"
        self.isPublic = isPublic
        self.createdAt = Date()
        self.startDate = Date()
        self.endDate = Date().addingTimeInterval(TimeInterval(durationDays * 24 * 60 * 60))
    }

    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "durationDays": durationDays,
            "type": type,
            "description": description,
            "stakeAmount": stakeAmount,
            "creatorId": creatorUID,
            "participants": participants,
            "invitedFriends": invitedFriends,
            "status": status,
            "isPublic": isPublic,
            "createdAt": FieldValue.serverTimestamp(),
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate)
        ]

        // Only include location fields if they exist
        if let locationName = locationName {
            dict["location"] = locationName
        }
        if let locationLatitude = locationLatitude {
            dict["locationLatitude"] = locationLatitude
        }
        if let locationLongitude = locationLongitude {
            dict["locationLongitude"] = locationLongitude
        }

        return dict
    }
}
