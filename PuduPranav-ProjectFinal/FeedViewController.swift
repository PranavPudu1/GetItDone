// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import FirebaseAuth

class FeedViewController: UIViewController {

    @IBOutlet weak var createChallengeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var feedItems: [FeedItem] = []
    private var sampleChallenges: [String: Challenge] = [:] // Map sample IDs to Challenge objects
    private let tokenBalanceLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Feed"
        setupTokenBalanceLabel()
        setupTableView()
        setupActions()
        loadFeedData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTokenBalance()
        loadFeedData()
    }

    private func setupTokenBalanceLabel() {
        // Create a stack view to hold icon and label
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center

        // Token icon
        let iconImageView = UIImageView(image: UIImage(systemName: "dumbbell.fill"))
        iconImageView.tintColor = UIColor(named: "AppPrimaryBrown")
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 16).isActive = true

        // Token label
        tokenBalanceLabel.font = UIFont.boldSystemFont(ofSize: 16)
        tokenBalanceLabel.textColor = UIColor(named: "AppPrimaryBrown")
        tokenBalanceLabel.text = "1,250"

        stackView.addArrangedSubview(tokenBalanceLabel)
        stackView.addArrangedSubview(iconImageView)

        let tokenBarButton = UIBarButtonItem(customView: stackView)
        navigationItem.rightBarButtonItem = tokenBarButton
    }

    private func loadTokenBalance() {
        let currentUserId = Auth.auth().currentUser?.uid ?? "demoUser1"
        let transactions = SampleData.sampleTransactions(for: currentUserId)
        let transactionSum = transactions.reduce(0) { $0 + $1.amount }
        let balance = 1000 + transactionSum

        tokenBalanceLabel.text = "\(balance)"
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: "FeedCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
    }

    private func loadFeedData() {
        // Create sample Challenge objects
        let challenge1 = Challenge(
            name: "East Village 1 Week Weight Training Challenge",
            durationDays: 7,
            type: "Strength",
            description: "Complete weight training sessions for 7 consecutive days at East Village Gym",
            stakeAmount: 50,
            locationName: "East Village Gym",
            locationLatitude: 40.7282,
            locationLongitude: -73.9842,
            creatorUID: "demoUser2",
            invitedFriends: [],
            isPublic: true
        )

        let challenge2 = Challenge(
            name: "30-Day Morning Run Challenge",
            durationDays: 30,
            type: "Cardio",
            description: "Run at least 3 miles every morning for 30 days",
            stakeAmount: 100,
            locationName: "Central Park",
            locationLatitude: 40.7829,
            locationLongitude: -73.9654,
            creatorUID: "demoUser4",
            invitedFriends: [],
            isPublic: true
        )

        let challenge3 = Challenge(
            name: "7-Day Squat Challenge",
            durationDays: 7,
            type: "Legs",
            description: "Complete 100 squats daily for a week",
            stakeAmount: 50,
            locationName: nil,
            locationLatitude: nil,
            locationLongitude: nil,
            creatorUID: "demoUser3",
            invitedFriends: [],
            isPublic: true
        )

        // Store sample challenges in dictionary
        sampleChallenges = [
            "sample1": challenge1,
            "sample2": challenge2,
            "sample3": challenge3
        ]

        // Hardcode sample public challenges to demonstrate functionality
        let sampleFeedItems = [
            FeedItem(
                id: "sample1",
                userId: "demoUser2",
                userName: "Peyton Manning",
                userInitial: "P",
                tokensChangeText: "+50 tokens",
                challengeTitle: "East Village 1 Week Weight Training Challenge",
                progressText: "1 participant",
                location: "East Village Gym",
                visibilityText: "Public",
                timestamp: Date(),
                challengeId: "sample1"
            ),
            FeedItem(
                id: "sample2",
                userId: "demoUser4",
                userName: "Tom Brady",
                userInitial: "T",
                tokensChangeText: "+100 tokens",
                challengeTitle: "30-Day Morning Run Challenge",
                progressText: "1 participant",
                location: "Central Park",
                visibilityText: "Public",
                timestamp: Date(),
                challengeId: "sample2"
            ),
            FeedItem(
                id: "sample3",
                userId: "demoUser3",
                userName: "Eli Manning",
                userInitial: "E",
                tokensChangeText: "+50 tokens",
                challengeTitle: "7-Day Squat Challenge",
                progressText: "1 participant",
                location: "No specific location",
                visibilityText: "Public",
                timestamp: Date(),
                challengeId: "sample3"
            )
        ]

        // Also load actual public challenges from Firebase
        FirebaseService.shared.fetchAllPublicChallenges { [weak self] result in
            switch result {
            case .success(let challenges):
                // Fetch creator profiles for each challenge
                let group = DispatchGroup()
                var feedItemsWithProfiles: [FeedItem] = []

                for challenge in challenges.prefix(10) {
                    group.enter()

                    FirebaseService.shared.fetchUserProfile(userId: challenge.creatorUID) { profileResult in
                        let feedItem: FeedItem

                        switch profileResult {
                        case .success(let profile):
                            feedItem = FeedItem(
                                id: challenge.id,
                                userId: challenge.creatorUID,
                                userName: profile.fullName,
                                userInitial: String(profile.firstName.prefix(1)),
                                tokensChangeText: "+\(challenge.stakeAmount) tokens",
                                challengeTitle: challenge.name,
                                progressText: "\(challenge.participants.count) participants",
                                location: challenge.locationName ?? "No specific location",
                                visibilityText: "Public",
                                timestamp: challenge.createdAt,
                                challengeId: challenge.id
                            )
                        case .failure:
                            // Fallback to generic display if profile fetch fails
                            feedItem = FeedItem(
                                id: challenge.id,
                                userId: challenge.creatorUID,
                                userName: "User",
                                userInitial: "U",
                                tokensChangeText: "+\(challenge.stakeAmount) tokens",
                                challengeTitle: challenge.name,
                                progressText: "\(challenge.participants.count) participants",
                                location: challenge.locationName ?? "No specific location",
                                visibilityText: "Public",
                                timestamp: challenge.createdAt,
                                challengeId: challenge.id
                            )
                        }

                        feedItemsWithProfiles.append(feedItem)
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    // Combine sample challenges with actual challenges
                    self?.feedItems = sampleFeedItems + feedItemsWithProfiles
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error loading feed: \(error.localizedDescription)")
                    // Show only sample challenges if Firebase fails
                    self?.feedItems = sampleFeedItems
                    self?.tableView.reloadData()
                }
            }
        }
    }

    private func setupActions() {
        createChallengeButton.addTarget(self, action: #selector(createChallengeTapped), for: .touchUpInside)
    }

    @objc private func createChallengeTapped() {
        // Navigate to Create Challenge screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let createVC = storyboard.instantiateViewController(withIdentifier: "create-challenge-vc") as? CreateChallengeViewController else {
            return
        }
        let navController = UINavigationController(rootViewController: createVC)
        present(navController, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as? FeedTableViewCell else {
            return UITableViewCell()
        }

        let feedItem = feedItems[indexPath.row]
        cell.configure(with: feedItem)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let feedItem = feedItems[indexPath.row]
        guard let challengeId = feedItem.challengeId, !challengeId.isEmpty else {
            return
        }

        // Check if this is a sample challenge
        if challengeId.hasPrefix("sample"), let challenge = sampleChallenges[challengeId] {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let detailVC = storyboard.instantiateViewController(withIdentifier: "ChallengeDetailViewController") as? ChallengeDetailViewController else {
                return
            }

            detailVC.challenge = challenge
            navigationController?.pushViewController(detailVC, animated: true)
            return
        }

        // Fetch the challenge from Firebase
        FirebaseService.shared.fetchAllPublicChallenges { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    guard let challenge = challenges.first(where: { $0.id == challengeId }) else {
                        return
                    }

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let detailVC = storyboard.instantiateViewController(withIdentifier: "ChallengeDetailViewController") as? ChallengeDetailViewController else {
                        return
                    }

                    detailVC.challenge = challenge
                    self?.navigationController?.pushViewController(detailVC, animated: true)
                case .failure(let error):
                    print("Error loading challenge: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Custom Feed Cell
class FeedTableViewCell: UITableViewCell {

    private let containerView = UIView()
    private let avatarLabel = UILabel()
    private let userNameLabel = UILabel()
    private let tokensLabel = UILabel()
    private let challengeTitleLabel = UILabel()
    private let progressLabel = UILabel()
    private let locationLabel = UILabel()
    private let visibilityLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        contentView.addSubview(containerView)

        // Avatar circle
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.textAlignment = .center
        avatarLabel.font = UIFont.boldSystemFont(ofSize: 20)
        avatarLabel.textColor = .white
        avatarLabel.backgroundColor = UIColor(named: "AppPrimaryBrown")
        avatarLabel.layer.cornerRadius = 20
        avatarLabel.clipsToBounds = true
        containerView.addSubview(avatarLabel)

        // User name label
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        userNameLabel.textColor = .label
        containerView.addSubview(userNameLabel)

        // Tokens label
        tokensLabel.translatesAutoresizingMaskIntoConstraints = false
        tokensLabel.font = UIFont.boldSystemFont(ofSize: 14)
        tokensLabel.textColor = .systemGreen
        tokensLabel.textAlignment = .right
        containerView.addSubview(tokensLabel)

        // Challenge title label
        challengeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        challengeTitleLabel.font = UIFont.systemFont(ofSize: 15)
        challengeTitleLabel.textColor = .secondaryLabel
        challengeTitleLabel.numberOfLines = 2
        containerView.addSubview(challengeTitleLabel)

        // Progress label
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        progressLabel.textColor = .label
        containerView.addSubview(progressLabel)

        // Location label
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        locationLabel.textColor = .secondaryLabel
        containerView.addSubview(locationLabel)

        // Visibility label
        visibilityLabel.translatesAutoresizingMaskIntoConstraints = false
        visibilityLabel.font = UIFont.systemFont(ofSize: 12)
        visibilityLabel.textColor = .gray
        visibilityLabel.textAlignment = .right
        containerView.addSubview(visibilityLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            avatarLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            avatarLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            avatarLabel.widthAnchor.constraint(equalToConstant: 40),
            avatarLabel.heightAnchor.constraint(equalToConstant: 40),

            userNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            userNameLabel.trailingAnchor.constraint(equalTo: tokensLabel.leadingAnchor, constant: -8),

            tokensLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            tokensLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            tokensLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            challengeTitleLabel.topAnchor.constraint(equalTo: avatarLabel.bottomAnchor, constant: 12),
            challengeTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            challengeTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            progressLabel.topAnchor.constraint(equalTo: challengeTitleLabel.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            progressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            locationLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: visibilityLabel.leadingAnchor, constant: -8),
            locationLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            visibilityLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 8),
            visibilityLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            visibilityLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            visibilityLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }

    func configure(with feedItem: FeedItem) {
        avatarLabel.text = feedItem.userInitial
        avatarLabel.backgroundColor = generateColor(from: feedItem.userName)
        userNameLabel.text = feedItem.userName
        tokensLabel.text = feedItem.tokensChangeText
        challengeTitleLabel.text = feedItem.challengeTitle
        progressLabel.text = feedItem.progressText
        locationLabel.text = "📍 \(feedItem.location)"
        visibilityLabel.text = feedItem.visibilityText
    }

    private func generateColor(from string: String) -> UIColor {
        let colors: [UIColor] = [
            UIColor(red: 0.478, green: 0.302, blue: 0.157, alpha: 1.0), // AppPrimaryBrown
            UIColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0),
            UIColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 1.0),
            UIColor(red: 0.7, green: 0.3, blue: 0.4, alpha: 1.0)
        ]
        let index = abs(string.hashValue) % colors.count
        return colors[index]
    }
}
