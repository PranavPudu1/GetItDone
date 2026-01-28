// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        // Background
        view.backgroundColor = UIColor(named: "AppBackground")
        
        // Logo - barbell icon
        logoImageView.image = UIImage(systemName: "dumbbell.fill")
        logoImageView.tintColor = UIColor(named: "AppPrimaryBrown")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.backgroundColor = .clear
        
        // Title
        titleLabel.textColor = UIColor(named: "AppPrimaryBrown")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        
        // Subtitle
        subtitleLabel.textColor = UIColor(named: "AppPrimaryBrown")
        subtitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        subtitleLabel.textAlignment = .center
        
        // Email TextField
        configureTextField(emailTextField, placeholder: "Email")
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        
        // Password TextField
        configureTextField(passwordTextField, placeholder: "Password")
        passwordTextField.isSecureTextEntry = true
        
        // Login Button
        loginButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        loginButton.layer.cornerRadius = 22
        loginButton.layer.masksToBounds = true
        
        // Create Account Button
        createAccountButton.setTitleColor(UIColor(named: "AppPrimaryBrown"), for: .normal)
        createAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createAccountButton.backgroundColor = .clear

        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter both email and password")
            return
        }

        // Login user with FirebaseService
        FirebaseService.shared.loginUser(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let userId):
                print("User logged in successfully with ID: \(userId)")
                DispatchQueue.main.async {
                    self?.switchToMainApp()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }

    @IBAction func createAccountTapped(_ sender: UIButton) {
        // Navigate to signup screen later
        // TODO: Implement navigation to registration screen
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
