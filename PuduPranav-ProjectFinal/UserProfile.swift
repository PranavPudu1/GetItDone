// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import Foundation
import FirebaseFirestore

struct UserProfile {
    let uid: String
    var firstName: String
    var lastName: String
    var username: String
    let email: String
    var phoneNumber: String
    var profileImageURL: String?
    var tokensBalance: Int

    // Initialize from Firestore document
    init(uid: String, data: [String: Any]) {
        self.uid = uid
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.phoneNumber = data["phone"] as? String ?? ""
        self.profileImageURL = data["profileImageURL"] as? String
        self.tokensBalance = data["tokensBalance"] as? Int ?? 0
    }

    // Initialize with parameters
    init(
        uid: String,
        firstName: String,
        lastName: String,
        username: String,
        email: String,
        phoneNumber: String,
        profileImageURL: String? = nil,
        tokensBalance: Int = 100
    ) {
        self.uid = uid
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImageURL = profileImageURL
        self.tokensBalance = tokensBalance
    }

    // Convert to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "username": username,
            "email": email,
            "phone": phoneNumber,
            "tokensBalance": tokensBalance
        ]

        if let imageURL = profileImageURL {
            dict["profileImageURL"] = imageURL
        }

        return dict
    }

    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}
