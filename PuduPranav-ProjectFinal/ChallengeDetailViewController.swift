// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import FirebaseAuth

class ChallengeDetailViewController: UIViewController {

    var challenge: Challenge!

    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let durationLabel = UILabel()
    private let visibilityLabel = UILabel()
    private let participantsHeaderLabel = UILabel()
    private let participantsStackView = UIStackView()
    private let tokenPoolContainer = UIView()
    private let tokenPoolLabel = UILabel()
    private let tokenAmountLabel = UILabel()
    private let tokenIconImageView = UIImageView()
    private let joinLeaveButton = UIButton()
    private let checkInButton = UIButton()
    private let rulesHeaderLabel = UILabel()
    private let rulesLabel = UILabel()

    // State
    private var isUserParticipating = false
    private var participantsList: [ChallengeParticipant] = []
    private var followedFriendIds: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Challenge Detail"
        checkUserParticipation()
        loadFollowedFriends()
        setupUI()
        displayChallengeInfo()
    }

    private func checkUserParticipation() {
        let currentUserId = Auth.auth().currentUser?.uid ?? "demoUser1"
        isUserParticipating = challenge.participants.contains(currentUserId)
    }

    private func loadFollowedFriends() {
        FirebaseService.shared.fetchFollowedFriends { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friendIds):
                    self?.followedFriendIds = friendIds
                    self?.updateParticipantsList()
                case .failure:
                    print("Error loading followed friends")
                }
            }
        }
    }

    private func setupUI() {
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "dumbbell.fill")
        iconImageView.tintColor = UIColor(named: "AppPrimaryBrown")
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)

        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = UIColor(named: "AppPrimaryBrown")
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)

        // Duration label
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.font = UIFont.systemFont(ofSize: 14)
        durationLabel.textColor = .darkGray
        durationLabel.textAlignment = .center
        contentView.addSubview(durationLabel)

        // Visibility label
        visibilityLabel.translatesAutoresizingMaskIntoConstraints = false
        visibilityLabel.font = UIFont.systemFont(ofSize: 14)
        visibilityLabel.textColor = .darkGray
        visibilityLabel.textAlignment = .center
        contentView.addSubview(visibilityLabel)

        // Participants header
        participantsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsHeaderLabel.text = "Participants"
        participantsHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        participantsHeaderLabel.textColor = UIColor(named: "AppPrimaryBrown")
        contentView.addSubview(participantsHeaderLabel)

        // Participants stack
        participantsStackView.translatesAutoresizingMaskIntoConstraints = false
        participantsStackView.axis = .vertical
        participantsStackView.spacing = 12
        participantsStackView.alignment = .leading
        contentView.addSubview(participantsStackView)

        // Token pool container
        tokenPoolContainer.translatesAutoresizingMaskIntoConstraints = false
        tokenPoolContainer.backgroundColor = .secondarySystemBackground
        tokenPoolContainer.layer.cornerRadius = 12
        tokenPoolContainer.layer.shadowColor = UIColor.black.cgColor
        tokenPoolContainer.layer.shadowOpacity = 0.1
        tokenPoolContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        tokenPoolContainer.layer.shadowRadius = 4
        contentView.addSubview(tokenPoolContainer)

        // Token pool label
        tokenPoolLabel.translatesAutoresizingMaskIntoConstraints = false
        tokenPoolLabel.text = "Token Pool"
        tokenPoolLabel.font = UIFont.systemFont(ofSize: 14)
        tokenPoolLabel.textColor = .darkGray
        tokenPoolLabel.textAlignment = .center
        tokenPoolContainer.addSubview(tokenPoolLabel)

        // Token amount label
        tokenAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        tokenAmountLabel.font = UIFont.boldSystemFont(ofSize: 32)
        tokenAmountLabel.textColor = UIColor(named: "AppPrimaryBrown")
        tokenAmountLabel.textAlignment = .center
        tokenPoolContainer.addSubview(tokenAmountLabel)

        // Token icon
        tokenIconImageView.image = UIImage(systemName: "dumbbell.fill")
        tokenIconImageView.translatesAutoresizingMaskIntoConstraints = false
        tokenIconImageView.tintColor = UIColor(named: "AppPrimaryBrown")
        tokenIconImageView.contentMode = .scaleAspectFit
        tokenPoolContainer.addSubview(tokenIconImageView)

        // Join/Leave button
        joinLeaveButton.translatesAutoresizingMaskIntoConstraints = false
        joinLeaveButton.setTitle("Join", for: .normal)
        joinLeaveButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
        joinLeaveButton.setTitleColor(.white, for: .normal)
        joinLeaveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        joinLeaveButton.layer.cornerRadius = 8
        joinLeaveButton.addTarget(self, action: #selector(joinLeaveButtonTapped), for: .touchUpInside)
        tokenPoolContainer.addSubview(joinLeaveButton)

        // Check-in button
        checkInButton.translatesAutoresizingMaskIntoConstraints = false
        checkInButton.setTitle("Check In", for: .normal)
        checkInButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
        checkInButton.setTitleColor(.white, for: .normal)
        checkInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        checkInButton.layer.cornerRadius = 8
        checkInButton.addTarget(self, action: #selector(checkInButtonTapped), for: .touchUpInside)
        tokenPoolContainer.addSubview(checkInButton)

        // Rules header
        rulesHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        rulesHeaderLabel.text = "Rules"
        rulesHeaderLabel.font = UIFont.boldSystemFont(ofSize: 16)
        rulesHeaderLabel.textColor = UIColor(named: "AppPrimaryBrown")
        contentView.addSubview(rulesHeaderLabel)

        // Rules label
        rulesLabel.translatesAutoresizingMaskIntoConstraints = false
        rulesLabel.font = UIFont.systemFont(ofSize: 14)
        rulesLabel.textColor = .darkGray
        rulesLabel.numberOfLines = 0
        contentView.addSubview(rulesLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            durationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            durationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            visibilityLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 4),
            visibilityLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            participantsHeaderLabel.topAnchor.constraint(equalTo: visibilityLabel.bottomAnchor, constant: 24),
            participantsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            participantsStackView.topAnchor.constraint(equalTo: participantsHeaderLabel.bottomAnchor, constant: 12),
            participantsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            participantsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            tokenPoolContainer.topAnchor.constraint(equalTo: participantsStackView.bottomAnchor, constant: 24),
            tokenPoolContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tokenPoolContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            tokenPoolLabel.topAnchor.constraint(equalTo: tokenPoolContainer.topAnchor, constant: 16),
            tokenPoolLabel.centerXAnchor.constraint(equalTo: tokenPoolContainer.centerXAnchor),

            tokenAmountLabel.topAnchor.constraint(equalTo: tokenPoolLabel.bottomAnchor, constant: 8),
            tokenAmountLabel.leadingAnchor.constraint(equalTo: tokenPoolContainer.leadingAnchor, constant: 20),
            tokenAmountLabel.trailingAnchor.constraint(equalTo: tokenIconImageView.leadingAnchor, constant: -8),

            tokenIconImageView.centerYAnchor.constraint(equalTo: tokenAmountLabel.centerYAnchor),
            tokenIconImageView.trailingAnchor.constraint(equalTo: tokenPoolContainer.trailingAnchor, constant: -20),
            tokenIconImageView.widthAnchor.constraint(equalToConstant: 28),
            tokenIconImageView.heightAnchor.constraint(equalToConstant: 28),

            joinLeaveButton.topAnchor.constraint(equalTo: tokenAmountLabel.bottomAnchor, constant: 16),
            joinLeaveButton.leadingAnchor.constraint(equalTo: tokenPoolContainer.leadingAnchor, constant: 20),
            joinLeaveButton.trailingAnchor.constraint(equalTo: tokenPoolContainer.trailingAnchor, constant: -20),
            joinLeaveButton.heightAnchor.constraint(equalToConstant: 44),

            checkInButton.topAnchor.constraint(equalTo: joinLeaveButton.bottomAnchor, constant: 12),
            checkInButton.leadingAnchor.constraint(equalTo: tokenPoolContainer.leadingAnchor, constant: 20),
            checkInButton.trailingAnchor.constraint(equalTo: tokenPoolContainer.trailingAnchor, constant: -20),
            checkInButton.heightAnchor.constraint(equalToConstant: 44),
            checkInButton.bottomAnchor.constraint(equalTo: tokenPoolContainer.bottomAnchor, constant: -16),

            rulesHeaderLabel.topAnchor.constraint(equalTo: tokenPoolContainer.bottomAnchor, constant: 24),
            rulesHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            rulesLabel.topAnchor.constraint(equalTo: rulesHeaderLabel.bottomAnchor, constant: 8),
            rulesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            rulesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rulesLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func displayChallengeInfo() {
        nameLabel.text = challenge.name
        durationLabel.text = "\(challenge.durationDays) days"
        visibilityLabel.text = "Public"

        // Calculate token pool
        let totalTokens = challenge.stakeAmount * challenge.participants.count
        tokenAmountLabel.text = "\(totalTokens)"

        // Update Join/Leave button
        updateJoinLeaveButton()

        // Build and display participants list
        updateParticipantsList()

        // Rules
        if let locationName = challenge.locationName {
            rulesLabel.text = "Let's hold each other accountable this week and see who can take home the most tokens!\n\nCheck in at \(locationName) to complete this challenge."
        } else {
            rulesLabel.text = "Let's hold each other accountable this week and see who can take home the most tokens!\n\nYou can check in from anywhere for this challenge."
        }
    }

    private func updateJoinLeaveButton() {
        if isUserParticipating {
            joinLeaveButton.setTitle("Leave Challenge", for: .normal)
            joinLeaveButton.backgroundColor = .systemGray
            checkInButton.isHidden = false
        } else {
            joinLeaveButton.setTitle("Join", for: .normal)
            joinLeaveButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
            checkInButton.isHidden = true
        }
    }

    private func updateParticipantsList() {
        // Clear existing participants
        participantsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Build participant list
        participantsList = challenge.participants.enumerated().map { index, participantId in
            // Find user in sample data
            let user = SampleData.sampleUsers.first { $0.uid == participantId } ?? UserProfile(
                uid: participantId,
                firstName: "User",
                lastName: "\(index + 1)",
                username: "user\(index + 1)",
                email: "user\(index + 1)@example.com",
                phoneNumber: ""
            )

            // Random progress for demo
            let progress = index + 2

            return ChallengeParticipant(from: user, progress: progress, totalDays: challenge.durationDays)
        }

        // Add participant views
        for participant in participantsList {
            let participantView = createParticipantView(participant: participant)
            participantsStackView.addArrangedSubview(participantView)
        }
    }

    private func createParticipantView(participant: ChallengeParticipant) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Make it tappable
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(participantTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.tag = participantsList.firstIndex(where: { $0.uid == participant.uid }) ?? 0

        // Avatar
        let avatarLabel = UILabel()
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.textAlignment = .center
        avatarLabel.font = UIFont.boldSystemFont(ofSize: 16)
        avatarLabel.textColor = .white
        avatarLabel.backgroundColor = UIColor(named: "AppPrimaryBrown")
        avatarLabel.layer.cornerRadius = 20
        avatarLabel.clipsToBounds = true
        avatarLabel.text = String(participant.name.first ?? "?")
        containerView.addSubview(avatarLabel)

        // Name label
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        nameLabel.textColor = .label
        nameLabel.text = participant.name
        containerView.addSubview(nameLabel)

        // Username label
        let usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.systemFont(ofSize: 13)
        usernameLabel.textColor = .secondaryLabel
        usernameLabel.text = "@\(participant.username)"
        containerView.addSubview(usernameLabel)

        // Progress label
        let progressLabel = UILabel()
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = UIFont.systemFont(ofSize: 13)
        progressLabel.textColor = .secondaryLabel
        progressLabel.text = "\(participant.progress)/\(participant.totalDays) completed"
        containerView.addSubview(progressLabel)

        // Follow button
        let followButton = UIButton()
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        followButton.layer.cornerRadius = 6
        followButton.tag = participantsList.firstIndex(where: { $0.uid == participant.uid }) ?? 0

        let isFollowing = followedFriendIds.contains(participant.uid)
        if isFollowing {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(.gray, for: .normal)
            followButton.backgroundColor = .systemGray5
            followButton.isEnabled = false
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
            followButton.addTarget(self, action: #selector(followButtonTapped(_:)), for: .touchUpInside)
        }

        containerView.addSubview(followButton)

        NSLayoutConstraint.activate([
            avatarLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            avatarLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            avatarLabel.widthAnchor.constraint(equalToConstant: 40),
            avatarLabel.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -8),

            usernameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            usernameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -8),

            progressLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            progressLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            progressLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -8),
            progressLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            followButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            followButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 80),
            followButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        return containerView
    }

    @objc private func joinLeaveButtonTapped() {
        if isUserParticipating {
            // Leave challenge
            if !challenge.id.isEmpty {
                FirebaseService.shared.leaveChallenge(challengeId: challenge.id) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.handleLeaveChallengeSuccess()
                        case .failure(let error):
                            print("Error leaving challenge: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                // Sample data - just update locally
                handleLeaveChallengeSuccess()
            }
        } else {
            // Join challenge
            if !challenge.id.isEmpty {
                FirebaseService.shared.joinChallenge(challengeId: challenge.id) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.handleJoinChallengeSuccess()
                        case .failure(let error):
                            print("Error joining challenge: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                // Sample challenge - create it in Firebase first, then join
                createAndJoinSampleChallenge()
            }
        }
    }

    private func createAndJoinSampleChallenge() {
        // Create the challenge in Firebase first
        FirebaseService.shared.createChallenge(challenge) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let challengeId):
                    // Update our local challenge with the new ID
                    guard let self = self else { return }

                    // Fetch the created challenge from Firebase to get the complete object with ID
                    FirebaseService.shared.fetchAllPublicChallenges { fetchResult in
                        DispatchQueue.main.async {
                            switch fetchResult {
                            case .success(let challenges):
                                if let createdChallenge = challenges.first(where: { $0.id == challengeId }) {
                                    self.challenge = createdChallenge

                                    // Now join it
                                    FirebaseService.shared.joinChallenge(challengeId: challengeId) { joinResult in
                                        DispatchQueue.main.async {
                                            switch joinResult {
                                            case .success:
                                                self.handleJoinChallengeSuccess()
                                            case .failure(let error):
                                                print("Error joining challenge: \(error.localizedDescription)")
                                                self.showAlert(title: "Error", message: "Failed to join challenge: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }
                            case .failure(let error):
                                print("Error fetching challenge: \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                    print("Error creating challenge: \(error.localizedDescription)")
                    self?.showAlert(title: "Error", message: "Failed to create challenge: \(error.localizedDescription)")
                }
            }
        }
    }

    private func handleJoinChallengeSuccess() {
        isUserParticipating = true
        updateJoinLeaveButton()

        // Reload the challenge from Firestore to get updated participants
        if !challenge.id.isEmpty {
            FirebaseService.shared.fetchChallenges { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let challenges):
                        if let updatedChallenge = challenges.first(where: { $0.id == self?.challenge.id }) {
                            self?.challenge = updatedChallenge
                        }
                        self?.updateParticipantsList()
                    case .failure:
                        self?.updateParticipantsList()
                    }
                }
            }
        } else {
            updateParticipantsList()
        }
    }

    private func handleLeaveChallengeSuccess() {
        isUserParticipating = false
        updateJoinLeaveButton()
        updateParticipantsList()
    }

    @objc private func followButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index < participantsList.count else { return }

        let participant = participantsList[index]
        let friend = FriendUser(uid: participant.uid, name: participant.name, username: participant.username)

        FirebaseService.shared.followFriend(friend: friend) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.followedFriendIds.insert(participant.uid)
                    self?.updateParticipantsList()
                case .failure(let error):
                    print("Error following friend: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc private func participantTapped(_ sender: UITapGestureRecognizer) {
        guard let containerView = sender.view else { return }
        let index = containerView.tag
        guard index < participantsList.count else { return }

        let participant = participantsList[index]

        // Find the corresponding UserProfile from sample data
        guard let user = SampleData.sampleUsers.first(where: { $0.uid == participant.uid }) else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {
            return
        }

        profileVC.userProfile = user
        navigationController?.pushViewController(profileVC, animated: true)
    }

    @objc private func checkInButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let checkInVC = storyboard.instantiateViewController(withIdentifier: "CheckInViewController") as? CheckInViewController else {
            return
        }

        checkInVC.challenge = challenge
        navigationController?.pushViewController(checkInVC, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
