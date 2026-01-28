// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import Foundation

struct FeedItem {
    let id: String
    let userId: String
    let userName: String
    let userInitial: String
    let tokensChangeText: String
    let challengeTitle: String
    let progressText: String
    let location: String
    let visibilityText: String
    let timestamp: Date
    let challengeId: String?
}

struct SampleData {

    // MARK: - Sample Users
    static let sampleUsers: [UserProfile] = [
        UserProfile(
            uid: "demoUser1",
            firstName: "Pranav",
            lastName: "Pudu",
            username: "pranavpudu1",
            email: "pranav@example.com",
            phoneNumber: "1234567890",
            tokensBalance: 1250
        ),
        UserProfile(
            uid: "demoUser2",
            firstName: "Peyton",
            lastName: "Manning",
            username: "peyton_123",
            email: "peyton@example.com",
            phoneNumber: "2345678901",
            tokensBalance: 980
        ),
        UserProfile(
            uid: "demoUser3",
            firstName: "Eli",
            lastName: "Manning",
            username: "eli_giants",
            email: "eli@example.com",
            phoneNumber: "3456789012",
            tokensBalance: 1100
        ),
        UserProfile(
            uid: "demoUser4",
            firstName: "Tom",
            lastName: "Brady",
            username: "tombradytb12",
            email: "tom@example.com",
            phoneNumber: "4567890123",
            tokensBalance: 1500
        ),
        UserProfile(
            uid: "demoUser5",
            firstName: "Aaron",
            lastName: "Rodgers",
            username: "aaronrodgers12",
            email: "aaron@example.com",
            phoneNumber: "5678901234",
            tokensBalance: 1350
        )
    ]

    // MARK: - Sample Friends
    static let sampleFriends: [UserProfile] = Array(sampleUsers.prefix(3))

    // MARK: - Sample Challenges
    static let sampleChallenges: [Challenge] = [
        Challenge(
            name: "East Village 1 Week Weight Training Challenge",
            durationDays: 7,
            type: "Strength",
            description: "Complete weight training sessions for 7 consecutive days at East Village Gym",
            stakeAmount: 50,
            locationName: "East Village Gym",
            locationLatitude: 40.7282,
            locationLongitude: -73.9842,
            creatorUID: "demoUser1",
            invitedFriends: ["demoUser2", "demoUser3"]
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
            creatorUID: "demoUser2",
            invitedFriends: ["demoUser1", "demoUser4"]
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
            creatorUID: "demoUser3",
            invitedFriends: ["demoUser1", "demoUser2", "demoUser5"]
        ),
        Challenge(
            name: "14-Day Abs Blaster",
            durationDays: 14,
            type: "Abs",
            description: "Core workout routine twice daily for two weeks",
            stakeAmount: 75,
            locationName: "Downtown Fitness Center",
            locationLatitude: 40.7580,
            locationLongitude: -73.9855,
            creatorUID: "demoUser4",
            invitedFriends: ["demoUser3"]
        ),
        Challenge(
            name: "21-Day Yoga Flow",
            durationDays: 21,
            type: "Cardio",
            description: "Daily yoga practice for mental and physical wellness",
            stakeAmount: 60,
            locationName: nil,
            locationLatitude: nil,
            locationLongitude: nil,
            creatorUID: "demoUser5",
            invitedFriends: ["demoUser2", "demoUser4"]
        )
    ]

    // MARK: - Sample Feed Items
    static let sampleFeedItems: [FeedItem] = {
        let now = Date()
        return [
            FeedItem(
                id: "feed1",
                userId: "demoUser3",
                userName: "Eli Manning",
                userInitial: "E",
                tokensChangeText: "+50 tokens",
                challengeTitle: "Eli joined East Village 1 Week Weight Training Challenge",
                progressText: "Progress: 4/7 days",
                location: "East Village Gym",
                visibilityText: "Friends only",
                timestamp: now.addingTimeInterval(-3600),
                challengeId: "0"
            ),
            FeedItem(
                id: "feed2",
                userId: "demoUser2",
                userName: "Peyton Manning",
                userInitial: "P",
                tokensChangeText: "+100 tokens",
                challengeTitle: "Peyton completed 30-Day Morning Run Challenge",
                progressText: "Progress: 30/30 days",
                location: "Central Park",
                visibilityText: "Public",
                timestamp: now.addingTimeInterval(-7200),
                challengeId: "1"
            ),
            FeedItem(
                id: "feed3",
                userId: "demoUser1",
                userName: "Pranav Pudu",
                userInitial: "P",
                tokensChangeText: "+75 tokens",
                challengeTitle: "Pranav started 14-Day Abs Blaster",
                progressText: "Progress: 1/14 days",
                location: "Downtown Fitness Center",
                visibilityText: "Friends only",
                timestamp: now.addingTimeInterval(-10800),
                challengeId: "3"
            ),
            FeedItem(
                id: "feed4",
                userId: "demoUser4",
                userName: "Tom Brady",
                userInitial: "T",
                tokensChangeText: "+50 tokens",
                challengeTitle: "Tom checked in to 7-Day Squat Challenge",
                progressText: "Progress: 5/7 days",
                location: "No specific location",
                visibilityText: "Public",
                timestamp: now.addingTimeInterval(-14400),
                challengeId: "2"
            ),
            FeedItem(
                id: "feed5",
                userId: "demoUser5",
                userName: "Aaron Rodgers",
                userInitial: "A",
                tokensChangeText: "+60 tokens",
                challengeTitle: "Aaron completed 21-Day Yoga Flow",
                progressText: "Progress: 21/21 days",
                location: "No specific location",
                visibilityText: "Friends only",
                timestamp: now.addingTimeInterval(-18000),
                challengeId: "4"
            )
        ]
    }()

    // MARK: - Sample Transactions
    static func sampleTransactions(for userId: String) -> [TokenTransaction] {
        let now = Date()
        let uid = userId.isEmpty ? "demoUser1" : userId

        return [
            TokenTransaction(
                id: "tx1",
                userId: uid,
                amount: 100,
                type: "earn",
                description: "Completed 30-Day Challenge",
                timestamp: now.addingTimeInterval(-86400 * 5)
            ),
            TokenTransaction(
                id: "tx2",
                userId: uid,
                amount: 50,
                type: "earn",
                description: "Weekly Check-In Bonus",
                timestamp: now.addingTimeInterval(-86400 * 4)
            ),
            TokenTransaction(
                id: "tx3",
                userId: uid,
                amount: 200,
                type: "earn",
                description: "Bought Extra Credits",
                timestamp: now.addingTimeInterval(-86400 * 2)
            ),
            TokenTransaction(
                id: "tx4",
                userId: uid,
                amount: -50,
                type: "spend",
                description: "Joined 7-Day Squat Challenge",
                timestamp: now.addingTimeInterval(-86400)
            ),
            TokenTransaction(
                id: "tx5",
                userId: uid,
                amount: 75,
                type: "earn",
                description: "Referred a Friend",
                timestamp: now.addingTimeInterval(-86400 * 6)
            ),
            TokenTransaction(
                id: "tx6",
                userId: uid,
                amount: -100,
                type: "spend",
                description: "Joined Morning Run Challenge",
                timestamp: now.addingTimeInterval(-86400 * 3)
            )
        ]
    }
}
