// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E


import FirebaseCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        // Seed public challenges once
        seedPublicChallengesIfNeeded()

        return true
    }

    private func seedPublicChallengesIfNeeded() {
        let hasSeededKey = "hasSeededPublicChallenges_v2" // Updated key to force re-seeding with isPublic field
        let hasSeeded = UserDefaults.standard.bool(forKey: hasSeededKey)

        if !hasSeeded {
            FirebaseService.shared.seedPublicChallenges { result in
                switch result {
                case .success:
                    print("Successfully seeded public challenges")
                    UserDefaults.standard.set(true, forKey: hasSeededKey)
                case .failure(let error):
                    print("Failed to seed public challenges: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

