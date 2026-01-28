// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import Foundation

struct FriendUser {
    let uid: String
    let name: String
    let username: String

    init(uid: String, name: String, username: String) {
        self.uid = uid
        self.name = name
        self.username = username
    }

    // Create from UserProfile
    init(from user: UserProfile) {
        self.uid = user.uid
        self.name = user.fullName
        self.username = user.username
    }

    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "uid": uid,
            "name": name,
            "username": username
        ]
    }

    // Initialize from Firestore document
    init(uid: String, data: [String: Any]) {
        self.uid = uid
        self.name = data["name"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
    }
}
