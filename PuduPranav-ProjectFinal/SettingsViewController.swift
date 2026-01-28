// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import UserNotifications

class SettingsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var notificationsSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Settings"
        setupActions()
        loadUserProfile()
        loadSettings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserProfile()
    }

    private func setupActions() {
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        darkModeSwitch.addTarget(self, action: #selector(darkModeChanged), for: .valueChanged)
        notificationsSwitch.addTarget(self, action: #selector(notificationsChanged), for: .valueChanged)
    }

    private func loadSettings() {
        // Load dark mode setting (defaults to OFF/light mode)
        let darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        darkModeSwitch.isOn = darkModeEnabled

        // Load notifications setting (defaults to OFF)
        let notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        notificationsSwitch.isOn = notificationsEnabled
    }

    private func loadUserProfile() {
        FirebaseService.shared.fetchCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.nameLabel.text = "\(profile.firstName) \(profile.lastName)"
                    self?.usernameLabel.text = "@\(profile.username)"

                    // Load profile image
                    if let imageURL = profile.profileImageURL, let url = URL(string: imageURL) {
                        self?.loadImage(from: url)
                    }
                case .failure(let error):
                    print("Failed to load profile: \(error.localizedDescription)")
                }
            }
        }

        // Load followers and following counts
        loadFollowerCounts()
    }

    private func loadFollowerCounts() {
        // Load following count
        FirebaseService.shared.fetchFollowedFriends { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friendIds):
                    self?.followingCountLabel.text = "\(friendIds.count)"
                case .failure:
                    self?.followingCountLabel.text = "0"
                }
            }
        }

        // Load followers count (people who follow you)
        FirebaseService.shared.fetchFollowers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let followerIds):
                    self?.followersCountLabel.text = "\(followerIds.count)"
                case .failure:
                    self?.followersCountLabel.text = "0"
                }
            }
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }

    @objc private func editProfileTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {
            return
        }
        navigationController?.pushViewController(profileVC, animated: true)
    }

    @objc private func darkModeChanged(_ sender: UISwitch) {
        // Save dark mode preference
        UserDefaults.standard.set(sender.isOn, forKey: "darkModeEnabled")

        // Apply dark mode
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = sender.isOn ? .dark : .light
            }
        }
    }

    @objc private func notificationsChanged(_ sender: UISwitch) {
        // Save notification preference
        UserDefaults.standard.set(sender.isOn, forKey: "notificationsEnabled")

        if sender.isOn {
            // Request notification permission
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
            }
        }
    }

    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            try FirebaseService.shared.logoutUser()

            // Navigate back to login screen
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let navController = storyboard.instantiateViewController(withIdentifier: "BYZ-38-t0r") as? UINavigationController else {
                return
            }

            window.rootViewController = navController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        } catch {
            showAlert(title: "Error", message: "Failed to logout: \(error.localizedDescription)")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
