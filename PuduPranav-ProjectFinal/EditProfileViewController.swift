// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit

class EditProfileViewController: UIViewController {

    // MARK: - UI Elements
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!

    // MARK: - Properties
    var currentProfile: UserProfile!
    private var selectedImage: UIImage?
    private var hasImageChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Edit Profile"
        setupUI()
        setupActions()
        populateFields()
    }

    private func setupUI() {
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupActions() {
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    private func populateFields() {
        firstNameTextField.text = currentProfile.firstName
        lastNameTextField.text = currentProfile.lastName
        phoneTextField.text = currentProfile.phoneNumber

        // Load profile image
        if let imageURLString = currentProfile.profileImageURL, let imageURL = URL(string: imageURLString) {
            loadImage(from: imageURL)
        } else {
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

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func changePhotoTapped() {
        let alertController = UIAlertController(title: "Choose Photo Source", message: nil, preferredStyle: .actionSheet)

        // Camera option
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            })
        }

        // Photo Library option
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        })

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = changePhotoButton
            popoverController.sourceRect = changePhotoButton.bounds
        }

        present(alertController, animated: true)
    }

    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }

        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Saving...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: loadingAlert.view.topAnchor, constant: 50)
        ])
        present(loadingAlert, animated: true)

        if hasImageChanged, let image = selectedImage {
            // Upload image first
            FirebaseService.shared.uploadProfileImage(image) { [weak self] result in
                switch result {
                case .success(let imageURL):
                    self?.updateProfile(firstName: firstName, lastName: lastName, phone: phone, imageURL: imageURL, loadingAlert: loadingAlert)
                case .failure(let error):
                    DispatchQueue.main.async {
                        loadingAlert.dismiss(animated: true) {
                            self?.showAlert(title: "Error", message: "Failed to upload image: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } else {
            // No image change, just update profile
            updateProfile(firstName: firstName, lastName: lastName, phone: phone, imageURL: currentProfile.profileImageURL, loadingAlert: loadingAlert)
        }
    }

    private func updateProfile(firstName: String, lastName: String, phone: String, imageURL: String?, loadingAlert: UIAlertController) {
        var updatedProfile = UserProfile(
            uid: currentProfile.uid,
            firstName: firstName,
            lastName: lastName,
            username: currentProfile.username,
            email: currentProfile.email,
            phoneNumber: phone,
            profileImageURL: imageURL,
            tokensBalance: currentProfile.tokensBalance
        )

        FirebaseService.shared.updateUserProfile(updatedProfile) { [weak self] result in
            DispatchQueue.main.async {
                loadingAlert.dismiss(animated: true) {
                    switch result {
                    case .success:
                        self?.showAlert(title: "Success", message: "Profile updated successfully!") {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    case .failure(let error):
                        self?.showAlert(title: "Error", message: "Failed to update profile: \(error.localizedDescription)")
                    }
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

// MARK: - UIImagePickerControllerDelegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
            profileImageView.image = editedImage
            profileImageView.tintColor = nil
            hasImageChanged = true
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            profileImageView.image = originalImage
            profileImageView.tintColor = nil
            hasImageChanged = true
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
