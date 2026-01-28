// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit

class ChallengesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var challenges: [Challenge] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Challenges"
        setupTableView()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchChallenges()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "AppBackground")
        tableView.register(ChallengeTableViewCell.self, forCellReuseIdentifier: "ChallengeCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }

    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChallengeTapped))
        addButton.tintColor = UIColor(named: "AppPrimaryBrown")
        navigationItem.rightBarButtonItem = addButton
    }

    @objc private func addChallengeTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let createVC = storyboard.instantiateViewController(withIdentifier: "create-challenge-vc") as? CreateChallengeViewController else {
            return
        }

        let navController = UINavigationController(rootViewController: createVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    private func fetchChallenges() {
        FirebaseService.shared.fetchChallenges { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let challenges):
                    // Only use Firebase challenges, don't show sample data for new users
                    self?.challenges = challenges
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching challenges: \(error.localizedDescription)")
                    // Show empty list on error instead of sample data
                    self?.challenges = []
                    self?.tableView.reloadData()
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

// MARK: - UITableViewDataSource
extension ChallengesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challenges.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChallengeCell", for: indexPath) as? ChallengeTableViewCell else {
            return UITableViewCell()
        }

        let challenge = challenges[indexPath.row]
        cell.configure(with: challenge)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChallengesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let challenge = challenges[indexPath.row]

        // Instantiate from storyboard to load outlets
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let checkInVC = storyboard.instantiateViewController(withIdentifier: "CheckInViewController") as? CheckInViewController else {
            return
        }

        checkInVC.challenge = challenge
        navigationController?.pushViewController(checkInVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let challenge = challenges[indexPath.row]

            // Show confirmation alert
            let alert = UIAlertController(
                title: "Delete Challenge",
                message: "Are you sure you want to delete '\(challenge.name)'? This action cannot be undone.",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self = self else { return }

                // Check if this is a sample challenge (has empty ID)
                if challenge.id.isEmpty {
                    // Just remove from local array for sample data
                    self.challenges.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    // Delete from Firebase
                    FirebaseService.shared.deleteChallenge(challengeId: challenge.id) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                self.challenges.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            case .failure(let error):
                                self.showAlert(title: "Error", message: "Failed to delete challenge: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            })

            present(alert, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

// MARK: - Custom Cell
class ChallengeTableViewCell: UITableViewCell {

    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let typeLabel = UILabel()
    private let infoLabel = UILabel()
    private let stakeLabel = UILabel()
    private let stakeStackView = UIStackView()
    private let stakeIconImageView = UIImageView()

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

        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 2
        containerView.addSubview(nameLabel)

        // Type label
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        typeLabel.textColor = .secondaryLabel
        containerView.addSubview(typeLabel)

        // Info label
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = .secondaryLabel
        containerView.addSubview(infoLabel)

        // Stake label
        stakeLabel.translatesAutoresizingMaskIntoConstraints = false
        stakeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        stakeLabel.textColor = .label
        stakeLabel.textAlignment = .right

        // Stake icon
        stakeIconImageView.translatesAutoresizingMaskIntoConstraints = false
        stakeIconImageView.image = UIImage(systemName: "dumbbell.fill")
        stakeIconImageView.tintColor = UIColor(named: "AppPrimaryBrown")
        stakeIconImageView.contentMode = .scaleAspectFit

        // Stack view for stake amount and icon
        stakeStackView.translatesAutoresizingMaskIntoConstraints = false
        stakeStackView.axis = .horizontal
        stakeStackView.spacing = 4
        stakeStackView.alignment = .center
        stakeStackView.addArrangedSubview(stakeLabel)
        stakeStackView.addArrangedSubview(stakeIconImageView)
        containerView.addSubview(stakeStackView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: stakeStackView.leadingAnchor, constant: -8),

            typeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),

            infoLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            infoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            infoLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            stakeStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stakeStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            stakeIconImageView.widthAnchor.constraint(equalToConstant: 16),
            stakeIconImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func configure(with challenge: Challenge) {
        nameLabel.text = challenge.name
        typeLabel.text = "🔥 \(challenge.type)"
        infoLabel.text = "\(challenge.durationDays) days • \(challenge.participants.count) participants"
        stakeLabel.text = "\(challenge.stakeAmount)"
    }
}
