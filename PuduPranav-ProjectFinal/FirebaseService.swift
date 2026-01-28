// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()

    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}

    // MARK: - User Registration
    func registerUser(
        firstName: String,
        lastName: String,
        email: String,
        phone: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let userId = authResult?.user.uid else {
                let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])
                completion(.failure(error))
                return
            }

            // Create user document in Firestore
            // Generate username from first name + last initial
            let username = "\(firstName.lowercased())\(lastName.prefix(1).lowercased())\(Int.random(in: 100...999))"

            let userData: [String: Any] = [
                "firstName": firstName,
                "lastName": lastName,
                "username": username,
                "email": email,
                "phone": phone,
                "tokensBalance": 100,
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ]

            self?.db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(userId))
            }
        }
    }

    // MARK: - User Login
    func loginUser(
        email: String,
        password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let userId = authResult?.user.uid else {
                let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])
                completion(.failure(error))
                return
            }

            completion(.success(userId))
        }
    }

    // MARK: - User Logout
    func logoutUser() throws {
        try auth.signOut()
    }

    // MARK: - Get Current User ID
    var currentUserId: String? {
        return auth.currentUser?.uid
    }

    // MARK: - Check if User is Logged In
    var isUserLoggedIn: Bool {
        return auth.currentUser != nil
    }

    // MARK: - Challenge Management
    func createChallenge(_ challenge: Challenge, completion: @escaping (Result<String, Error>) -> Void) {
        let challengeData = challenge.toDictionary()

        print("Creating challenge with participants: \(challenge.participants)")
        print("Challenge data: \(challengeData)")

        var documentRef: DocumentReference?
        documentRef = db.collection("challenges").addDocument(data: challengeData) { error in
            if let error = error {
                print("Error creating challenge: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let docID = documentRef?.documentID {
                print("Challenge created successfully with ID: \(docID)")
                completion(.success(docID))
            } else {
                completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get document ID"])))
            }
        }
    }

    // MARK: - Database Seeding
    func seedPublicChallenges(completion: @escaping (Result<Void, Error>) -> Void) {
        // Create 3 sample public challenges
        let challenges = [
            Challenge(
                name: "East Village 1 Week Weight Training Challenge",
                durationDays: 7,
                type: "Strength",
                description: "Complete weight training sessions for 7 consecutive days at East Village Gym",
                stakeAmount: 50,
                locationName: "East Village Gym",
                locationLatitude: 40.7282,
                locationLongitude: -73.9842,
                creatorUID: "demoUser2", // Peyton
                invitedFriends: [],
                isPublic: true
            ),
            Challenge(
                name: "30-Day Morning Run Challenge",
                durationDays: 30,
                type: "Cardio",
                description: "Run at least 3 miles every morning for 30 days",
                stakeAmount: 100,
                locationName: "Central Park",
                locationLatitude: 40.7829,
                locationLongitude: -73.9654,
                creatorUID: "demoUser4", // Tom Brady
                invitedFriends: [],
                isPublic: true
            ),
            Challenge(
                name: "7-Day Squat Challenge",
                durationDays: 7,
                type: "Legs",
                description: "Complete 100 squats daily for a week",
                stakeAmount: 50,
                locationName: nil,
                locationLatitude: nil,
                locationLongitude: nil,
                creatorUID: "demoUser3", // Eli Manning
                invitedFriends: [],
                isPublic: true
            )
        ]

        let group = DispatchGroup()
        var errors: [Error] = []

        for challenge in challenges {
            group.enter()
            createChallenge(challenge) { result in
                if case .failure(let error) = result {
                    errors.append(error)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if errors.isEmpty {
                print("Successfully seeded \(challenges.count) challenges")
                completion(.success(()))
            } else {
                completion(.failure(errors.first!))
            }
        }
    }

    func fetchChallenges(completion: @escaping (Result<[Challenge], Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            // If no user logged in, return empty array
            completion(.success([]))
            return
        }

        // Fetch challenges where user is a participant
        // Note: Remove orderBy to avoid needing a composite index
        print("Fetching challenges for user: \(currentUserId)")

        db.collection("challenges")
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching challenges: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    completion(.success([]))
                    return
                }

                print("Found \(documents.count) challenges")

                var challenges = documents.compactMap { doc -> Challenge? in
                    let data = doc.data()
                    print("Challenge doc: \(doc.documentID), participants: \(data["participants"] ?? "none")")
                    return Challenge(id: doc.documentID, data: data)
                }

                // Sort by creation date in memory
                challenges.sort { $0.createdAt > $1.createdAt }

                print("Returning \(challenges.count) challenges")
                completion(.success(challenges))
            }
    }

    func fetchAllPublicChallenges(completion: @escaping (Result<[Challenge], Error>) -> Void) {
        db.collection("challenges")
            .whereField("isPublic", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching all challenges: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }

                var challenges = documents.compactMap { doc -> Challenge? in
                    let data = doc.data()
                    return Challenge(id: doc.documentID, data: data)
                }

                // Sort by creation date in memory
                challenges.sort { $0.createdAt > $1.createdAt }

                completion(.success(challenges))
            }
    }

    func fetchUserChallenges(userId: String, completion: @escaping (Result<[Challenge], Error>) -> Void) {
        print("Fetching challenges for user: \(userId)")

        db.collection("challenges")
            .whereField("participants", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user challenges: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found for user")
                    completion(.success([]))
                    return
                }

                print("Found \(documents.count) challenges for user")

                var challenges = documents.compactMap { doc -> Challenge? in
                    let data = doc.data()
                    return Challenge(id: doc.documentID, data: data)
                }

                // Sort by creation date in memory (most recent first)
                challenges.sort { $0.createdAt > $1.createdAt }

                print("Returning \(challenges.count) challenges for user")
                completion(.success(challenges))
            }
    }

    func deleteChallenge(challengeId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !challengeId.isEmpty else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid challenge ID"])
            completion(.failure(error))
            return
        }

        db.collection("challenges").document(challengeId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    // MARK: - User Profile Management
    func fetchCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        db.collection("users").document(currentUserId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
                completion(.failure(error))
                return
            }

            let profile = UserProfile(uid: currentUserId, data: data)
            completion(.success(profile))
        }
    }

    func fetchUserProfile(userId: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
                completion(.failure(error))
                return
            }

            let profile = UserProfile(uid: userId, data: data)
            completion(.success(profile))
        }
    }

    func updateUserProfile(_ profile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        let profileData = profile.toDictionary()

        db.collection("users").document(profile.uid).updateData(profileData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func updateTokenBalance(newBalance: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        db.collection("users").document(currentUserId).updateData([
            "tokensBalance": newBalance
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        // Compress image
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
            completion(.failure(error))
            return
        }

        // Create storage reference
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profileImages/\(currentUserId).jpg")

        // Upload image
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        profileImageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            // Get download URL
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url?.absoluteString else {
                    let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])
                    completion(.failure(error))
                    return
                }

                completion(.success(downloadURL))
            }
        }
    }

    // MARK: - Check-In Management
    func saveCheckIn(
        challengeId: String,
        latitude: Double?,
        longitude: Double?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        var checkInData: [String: Any] = [
            "challengeId": challengeId,
            "userId": currentUserId,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // Only include location if provided
        if let latitude = latitude {
            checkInData["latitude"] = latitude
        }
        if let longitude = longitude {
            checkInData["longitude"] = longitude
        }

        db.collection("checkIns").addDocument(data: checkInData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    // MARK: - Friend Management
    func followFriend(friend: FriendUser, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        db.collection("users").document(currentUserId).collection("friends").document(friend.uid)
            .setData(friend.toDictionary()) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }

    func unfollowFriend(friendId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        db.collection("users").document(currentUserId).collection("friends").document(friendId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }

    func fetchFollowedFriends(completion: @escaping (Result<Set<String>, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        db.collection("users").document(currentUserId).collection("friends")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let friendIds = Set(snapshot?.documents.map { $0.documentID } ?? [])
                completion(.success(friendIds))
            }
    }

    func fetchFollowedFriendsDetails(completion: @escaping (Result<[FriendUser], Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        db.collection("users").document(currentUserId).collection("friends")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let friends = snapshot?.documents.compactMap { doc -> FriendUser? in
                    return FriendUser(uid: doc.documentID, data: doc.data())
                } ?? []

                completion(.success(friends))
            }
    }

    func fetchFollowers(completion: @escaping (Result<Set<String>, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        // Query all users' friends subcollections to find who has current user as a friend
        // We need to use a field query instead of documentID
        db.collectionGroup("friends")
            .whereField("uid", isEqualTo: currentUserId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching followers: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                // Get the parent document IDs (the users who follow the current user)
                let followerIds = Set(snapshot?.documents.compactMap { doc -> String? in
                    // The reference path is: users/{userId}/friends/{friendId}
                    // We want the userId part
                    let pathComponents = doc.reference.path.components(separatedBy: "/")
                    if pathComponents.count >= 2 {
                        return pathComponents[1] // users/{userId}/friends/{friendId}
                    }
                    return nil
                } ?? [])

                print("Found \(followerIds.count) followers")
                completion(.success(followerIds))
            }
    }

    // MARK: - Challenge Join/Leave
    func joinChallenge(challengeId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        db.collection("challenges").document(challengeId)
            .updateData([
                "participants": FieldValue.arrayUnion([currentUserId])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }

    func leaveChallenge(challengeId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = currentUserId else {
            let error = NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
            completion(.failure(error))
            return
        }

        db.collection("challenges").document(challengeId)
            .updateData([
                "participants": FieldValue.arrayRemove([currentUserId])
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }
}
