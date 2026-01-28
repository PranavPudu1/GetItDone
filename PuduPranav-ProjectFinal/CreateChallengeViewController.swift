// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit

class CreateChallengeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var challengeNameTextField: UITextField!
    @IBOutlet weak var durationStepper: UIStepper!
    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var typeSegmentControl: UISegmentedControl!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var friendsTextField: UITextField!
    @IBOutlet weak var stakeAmountTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var chooseLocationButton: UIButton!

    // MARK: - Properties
    private let visibilitySegmentControl = UISegmentedControl(items: ["Public", "Friends Only"])
    private let visibilityLabel = UILabel()
    private var selectedLocationName: String?
    private var selectedLatitude: Double?
    private var selectedLongitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupUI()
    }

    private func setupUI() {
        // Set initial duration value
        durationValueLabel.text = "\(Int(durationStepper.value)) days"

        // Setup visibility label
        visibilityLabel.translatesAutoresizingMaskIntoConstraints = false
        visibilityLabel.text = "Visibility"
        visibilityLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        visibilityLabel.textColor = UIColor(named: "AppPrimaryBrown")
        view.addSubview(visibilityLabel)

        // Setup visibility segmented control
        visibilitySegmentControl.translatesAutoresizingMaskIntoConstraints = false
        visibilitySegmentControl.selectedSegmentIndex = 1 // Default to Friends Only
        visibilitySegmentControl.backgroundColor = .secondarySystemBackground
        visibilitySegmentControl.selectedSegmentTintColor = UIColor(named: "AppPrimaryBrown")
        visibilitySegmentControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        visibilitySegmentControl.setTitleTextAttributes([.foregroundColor: UIColor(named: "AppPrimaryBrown") ?? .brown], for: .normal)
        view.addSubview(visibilitySegmentControl)

        // Position visibility controls below type segment control
        NSLayoutConstraint.activate([
            visibilityLabel.topAnchor.constraint(equalTo: typeSegmentControl.bottomAnchor, constant: 20),
            visibilityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            visibilityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            visibilitySegmentControl.topAnchor.constraint(equalTo: visibilityLabel.bottomAnchor, constant: 8),
            visibilitySegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            visibilitySegmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            visibilitySegmentControl.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Add border to description text view
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor(named: "AppPrimaryBrown")?.withAlphaComponent(0.3).cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)

        // Reposition description text view to appear below visibility control
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        // Remove any existing constraints that might conflict
        view.constraints.forEach { constraint in
            if (constraint.firstItem as? UITextView) == descriptionTextView && constraint.firstAttribute == .top {
                constraint.isActive = false
            }
            if (constraint.secondItem as? UITextView) == descriptionTextView && constraint.secondAttribute == .top {
                constraint.isActive = false
            }
        }

        // Add new constraint to position below visibility control
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: visibilitySegmentControl.bottomAnchor, constant: 20)
        ])

        // Setup location label
        locationLabel.text = "No Location (Optional)"
        locationLabel.textColor = .gray

        // Setup choose location button
        chooseLocationButton.addTarget(self, action: #selector(chooseLocationTapped), for: .touchUpInside)

        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func chooseLocationTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pickLocationVC = storyboard.instantiateViewController(withIdentifier: "PickLocationViewController") as? PickLocationViewController else {
            return
        }

        pickLocationVC.delegate = self
        navigationController?.pushViewController(pickLocationVC, animated: true)
    }

    // MARK: - Actions
    @IBAction func durationChanged(_ sender: UIStepper) {
        let days = Int(sender.value)
        durationValueLabel.text = "\(days) days"
    }

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    @IBAction func createButtonTapped(_ sender: UIButton) {
        guard let challengeName = challengeNameTextField.text, !challengeName.isEmpty else {
            showAlert(title: "Error", message: "Please enter a challenge name")
            return
        }

        guard let description = descriptionTextView.text, !description.isEmpty else {
            showAlert(title: "Error", message: "Please enter a description")
            return
        }

        guard let stakeText = stakeAmountTextField.text, !stakeText.isEmpty,
              let stakeAmount = Int(stakeText), stakeAmount > 0 else {
            showAlert(title: "Error", message: "Please enter a valid stake amount")
            return
        }

        // Get selected challenge type
        let challengeTypes = ["Cardio", "Strength", "Legs", "Abs"]
        let selectedType = challengeTypes[typeSegmentControl.selectedSegmentIndex]

        // Parse friends emails
        let friendsEmails = parseFriendsEmails(from: friendsTextField.text ?? "")

        // Get duration
        let duration = Int(durationStepper.value)

        // Get visibility (0 = Public, 1 = Friends Only)
        let isPublic = visibilitySegmentControl.selectedSegmentIndex == 0

        // Create challenge
        createChallenge(
            name: challengeName,
            description: description,
            type: selectedType,
            duration: duration,
            stakeAmount: stakeAmount,
            friends: friendsEmails,
            isPublic: isPublic
        )
    }

    // MARK: - Helper Methods
    private func parseFriendsEmails(from text: String) -> [String] {
        return text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func createChallenge(
        name: String,
        description: String,
        type: String,
        duration: Int,
        stakeAmount: Int,
        friends: [String],
        isPublic: Bool
    ) {
        guard let currentUserId = FirebaseService.shared.currentUserId else {
            showAlert(title: "Error", message: "You must be logged in to create a challenge")
            return
        }

        // Create Challenge model with optional location
        let challenge = Challenge(
            name: name,
            durationDays: duration,
            type: type,
            description: description,
            stakeAmount: stakeAmount,
            locationName: selectedLocationName,
            locationLatitude: selectedLatitude,
            locationLongitude: selectedLongitude,
            creatorUID: currentUserId,
            invitedFriends: friends,
            isPublic: isPublic
        )

        // Save to Firestore using FirebaseService
        FirebaseService.shared.createChallenge(challenge) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let challengeId):
                    print("Challenge created with ID: \(challengeId)")
                    self?.showAlert(title: "Success", message: "Challenge created successfully!") {
                        self?.dismiss(animated: true)
                    }
                case .failure(let error):
                    self?.showAlert(title: "Error", message: "Failed to create challenge: \(error.localizedDescription)")
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

// MARK: - PickLocationDelegate
extension CreateChallengeViewController: PickLocationDelegate {
    func didPickLocation(name: String, latitude: Double, longitude: Double) {
        selectedLocationName = name
        selectedLatitude = latitude
        selectedLongitude = longitude

        // Update location label
        locationLabel.text = name
        locationLabel.textColor = UIColor(named: "AppPrimaryBrown")
    }
}
