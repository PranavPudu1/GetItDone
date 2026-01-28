// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tokensLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    var userProfile: UserProfile? // Set this from external view controllers
    private var currentProfile: UserProfile?
    private var isFollowing = false
    private var recentActivities: [Challenge] = []

    // Recent Activity UI
    private let recentActivityHeaderLabel = UILabel()
    private let recentActivityStackView = UIStackView()
    private let scrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Profile"
        setupUI()
        setupActions()
        setupRecentActivitySection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // If userProfile is set externally, use it (friend profile); otherwise load from Firebase (current user)
        if let profile = userProfile {
            configureButtonForFriendProfile()
            displayProfile(profile)
        } else {
            configureButtonForCurrentUser()
            loadUserProfile()
        }
    }

    private func setupUI() {
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }

    private func setupRecentActivitySection() {
        // Header label
        recentActivityHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        recentActivityHeaderLabel.text = "Recent Activity"
        recentActivityHeaderLabel.font = UIFont.boldSystemFont(ofSize: 18)
        recentActivityHeaderLabel.textColor = UIColor(named: "AppPrimaryBrown")
        view.addSubview(recentActivityHeaderLabel)

        // Stack view for activities
        recentActivityStackView.translatesAutoresizingMaskIntoConstraints = false
        recentActivityStackView.axis = .vertical
        recentActivityStackView.spacing = 12
        recentActivityStackView.alignment = .fill
        view.addSubview(recentActivityStackView)

        // Position below edit button (estimate 400 points from top)
        NSLayoutConstraint.activate([
            recentActivityHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 400),
            recentActivityHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recentActivityHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            recentActivityStackView.topAnchor.constraint(equalTo: recentActivityHeaderLabel.bottomAnchor, constant: 12),
            recentActivityStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            recentActivityStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func loadRecentActivity() {
        guard let profile = currentProfile else { return }

        // Fetch user's challenges to show as recent activity
        FirebaseService.shared.fetchUserChallenges(userId: profile.uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    self?.recentActivities = Array(challenges.prefix(3))
                    self?.displayRecentActivities()
                case .failure(let error):
                    print("Error loading recent activities: \(error.localizedDescription)")
                }
            }
        }
    }

    private func displayRecentActivities() {
        // Clear existing activities
        recentActivityStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if recentActivities.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No recent activity"
            emptyLabel.font = UIFont.systemFont(ofSize: 14)
            emptyLabel.textColor = .gray
            emptyLabel.textAlignment = .center
            recentActivityStackView.addArrangedSubview(emptyLabel)
            return
        }

        for activity in recentActivities {
            let activityView = createActivityView(challenge: activity)
            recentActivityStackView.addArrangedSubview(activityView)
        }
    }

    private func createActivityView(challenge: Challenge) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4

        // Icon
        let iconImageView = UIImageView(image: UIImage(systemName: "dumbbell.fill"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = UIColor(named: "AppPrimaryBrown")
        iconImageView.contentMode = .scaleAspectFit
        containerView.addSubview(iconImageView)

        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2
        titleLabel.text = "\(currentProfile?.firstName ?? "User") joined \(challenge.name)"
        containerView.addSubview(titleLabel)

        // Days label
        let daysLabel = UILabel()
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.font = UIFont.systemFont(ofSize: 12)
        daysLabel.textColor = .secondaryLabel

        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: challenge.createdAt, to: Date()).day ?? 0
        daysLabel.text = "\(days) days ago"
        containerView.addSubview(daysLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            daysLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            daysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            daysLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            daysLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])

        return containerView
    }

    private func setupActions() {
        // Button action will be configured based on profile type in viewWillAppear
    }

    private func loadUserProfile() {
        FirebaseService.shared.fetchCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.currentProfile = profile
                    self?.updateUI(with: profile)
                    self?.loadRecentActivity()
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Failed to load profile: \(error.localizedDescription)")
                }
            }
        }
    }

    private func displayProfile(_ profile: UserProfile) {
        currentProfile = profile
        updateUI(with: profile)
        loadRecentActivity()
    }

    private func updateUI(with profile: UserProfile) {
        nameLabel.text = profile.fullName
        emailLabel.text = profile.email
        tokensLabel.text = "\(profile.tokensBalance) Tokens"

        // Load profile image
        if let imageURLString = profile.profileImageURL, let imageURL = URL(string: imageURLString) {
            loadImage(from: imageURL)
        } else {
            // Set default placeholder
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            profileImageView.tintColor = UIColor(named: "AppPrimaryBrown")?.withAlphaComponent(0.5)
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }

            DispatchQueue.main.async {
                self?.profileImageView.image = image
                self?.profileImageView.tintColor = nil
            }
        }.resume()
    }

    private func configureButtonForCurrentUser() {
        editButton.setTitle("Edit Profile", for: .normal)
        editButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
        editButton.removeTarget(nil, action: nil, for: .allEvents)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    private func configureButtonForFriendProfile() {
        // Check if already following
        guard let friendId = userProfile?.uid else { return }

        FirebaseService.shared.fetchFollowedFriends { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let followedIds):
                    self?.isFollowing = followedIds.contains(friendId)
                    self?.updateFollowButton()
                case .failure:
                    self?.isFollowing = false
                    self?.updateFollowButton()
                }
            }
        }
    }

    private func updateFollowButton() {
        if isFollowing {
            editButton.setTitle("Following", for: .normal)
            editButton.backgroundColor = .systemGray
        } else {
            editButton.setTitle("Follow", for: .normal)
            editButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
        }
        editButton.removeTarget(nil, action: nil, for: .allEvents)
        editButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }

    @objc private func editButtonTapped() {
        guard let profile = currentProfile else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as? EditProfileViewController else {
            return
        }

        editVC.currentProfile = profile
        navigationController?.pushViewController(editVC, animated: true)
    }

    @objc private func followButtonTapped() {
        guard let friendProfile = userProfile else { return }

        if isFollowing {
            // Unfollow
            FirebaseService.shared.unfollowFriend(friendId: friendProfile.uid) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.isFollowing = false
                        self?.updateFollowButton()
                    case .failure(let error):
                        self?.showAlert(title: "Error", message: "Failed to unfollow: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Follow
            let friend = FriendUser(from: friendProfile)
            FirebaseService.shared.followFriend(friend: friend) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.isFollowing = true
                        self?.updateFollowButton()
                    case .failure(let error):
                        self?.showAlert(title: "Error", message: "Failed to follow: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
