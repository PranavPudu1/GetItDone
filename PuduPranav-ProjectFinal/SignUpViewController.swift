// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        // Background
        view.backgroundColor = UIColor(named: "AppBackground")

        // Logo - barbell icon 
        if let logoImageView = logoImageView {
            logoImageView.image = UIImage(systemName: "dumbbell.fill")
            logoImageView.tintColor = UIColor(named: "AppPrimaryBrown")
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.backgroundColor = .clear
        }

        // Title
        titleLabel.textColor = UIColor(named: "AppPrimaryBrown")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        
        // Subtitle
        subtitleLabel.textColor = UIColor(named: "AppPrimaryBrown")
        subtitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        subtitleLabel.textAlignment = .center
        
        // Text Fields
        configureTextField(firstNameTextField, placeholder: "First Name")
        firstNameTextField.textContentType = .givenName
        firstNameTextField.autocapitalizationType = .words
        
        configureTextField(lastNameTextField, placeholder: "Last Name")
        lastNameTextField.textContentType = .familyName
        lastNameTextField.autocapitalizationType = .words
        
        configureTextField(emailTextField, placeholder: "Email")
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.textContentType = .emailAddress
        
        configureTextField(phoneTextField, placeholder: "Phone Number")
        phoneTextField.keyboardType = .phonePad
        phoneTextField.textContentType = .telephoneNumber
        
        configureTextField(passwordTextField, placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .newPassword
        
        configureTextField(confirmPasswordTextField, placeholder: "Confirm Password")
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.textContentType = .newPassword
        
        // Sign Up Button
        signUpButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        signUpButton.layer.cornerRadius = 22
        signUpButton.layer.masksToBounds = true
        
        // Login Button (text only)
        loginButton.setTitleColor(UIColor(named: "AppPrimaryBrown"), for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        loginButton.backgroundColor = .clear
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemBackground
        textField.textColor = .label
        
        let placeholderColor = UIColor(named: "AppPrimaryBrown")?.withAlphaComponent(0.6) ?? .lightGray
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: placeholderColor]
        )
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(named: "AppPrimaryBrown")?.withAlphaComponent(0.3).cgColor
        textField.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    @IBAction func signUpTapped(_ sender: UIButton) {
        // Validate all fields
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }

        // Validate email format
        guard isValidEmail(email) else {
            showAlert(title: "Error", message: "Please enter a valid email address")
            return
        }

        // Validate password match
        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Passwords do not match")
            return
        }

        // Validate password length
        guard password.count >= 6 else {
            showAlert(title: "Error", message: "Password must be at least 6 characters")
            return
        }

        // Register user with FirebaseService
        FirebaseService.shared.registerUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            password: password
        ) { [weak self] result in
            switch result {
            case .success(let userId):
                print("User created successfully with ID: \(userId)")
                DispatchQueue.main.async {
                    self?.switchToMainApp()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        // Navigate back to login screen
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func switchToMainApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
            return
        }

        window.rootViewController = tabBarController
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
