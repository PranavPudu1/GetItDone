// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import Foundation

struct ChallengeParticipant {
    let uid: String
    let name: String
    let username: String
    var progress: Int
    let totalDays: Int

    init(uid: String, name: String, username: String, progress: Int, totalDays: Int) {
        self.uid = uid
        self.name = name
        self.username = username
        self.progress = progress
        self.totalDays = totalDays
    }

    // Create from UserProfile
    init(from user: UserProfile, progress: Int, totalDays: Int) {
        self.uid = user.uid
        self.name = user.fullName
        self.username = user.username
        self.progress = progress
        self.totalDays = totalDays
    }
}
