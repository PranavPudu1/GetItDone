// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import FirebaseAuth

class TokensViewController: UIViewController {
    @IBOutlet weak var tokensIconImageView: UIImageView!
    @IBOutlet weak var tokensBalanceLabel: UILabel!
    @IBOutlet weak var addTokensButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    private var transactions: [TokenTransaction] = []
    private var calculatedBalance: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Tokens"
        setupTableView()
        loadTransactions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTransactions()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
    }

    private func loadTransactions() {
        // Get current user ID or use demo user
        let currentUserId = Auth.auth().currentUser?.uid ?? "demoUser1"

        // Load sample transactions
        transactions = SampleData.sampleTransactions(for: currentUserId)

        // Calculate balance (base 1000 + sum of transactions)
        let transactionSum = transactions.reduce(0) { $0 + $1.amount }
        calculatedBalance = 1000 + transactionSum

        // Update UI
        tokensBalanceLabel.text = "\(calculatedBalance)"
        tableView.reloadData()
    }

    @IBAction func addTokensButtonTapped(_ sender: UIButton) {
        addTokensButton(sender)
    }

    @IBAction func addTokensButton(_ sender: UIButton) {
        let currentUserId = Auth.auth().currentUser?.uid ?? "demoUser1"

        // Add 500 tokens to balance
        let newTransaction = TokenTransaction(
            id: UUID().uuidString,
            userId: currentUserId,
            amount: 500,
            type: "purchase",
            description: "Token Purchase",
            timestamp: Date()
        )

        // Add transaction to the list
        transactions.insert(newTransaction, at: 0)

        // Update balance
        calculatedBalance += 500
        tokensBalanceLabel.text = "\(calculatedBalance)"

        // Update in Firebase (if user is logged in)
        if !currentUserId.isEmpty && currentUserId != "demoUser1" {
            FirebaseService.shared.updateTokenBalance(newBalance: calculatedBalance) { result in
                switch result {
                case .success:
                    print("Token balance updated in Firebase")
                case .failure(let error):
                    print("Error updating token balance: \(error.localizedDescription)")
                }
            }
        }

        // Reload table
        tableView.reloadData()

        // Show success alert
        let alert = UIAlertController(
            title: "Purchase Successful",
            message: "$0.00\n500 tokens added",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TokensViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionTableViewCell else {
            return UITableViewCell()
        }

        let transaction = transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
}

// MARK: - Custom Transaction Cell
class TransactionTableViewCell: UITableViewCell {

    private let descriptionLabel = UILabel()
    private let amountLabel = UILabel()
    private let separatorView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor(named: "AppBackground")
        selectionStyle = .none

        // Description label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = UIColor(named: "AppPrimaryBrown")
        contentView.addSubview(descriptionLabel)

        // Amount label
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = UIFont.boldSystemFont(ofSize: 16)
        amountLabel.textAlignment = .right
        contentView.addSubview(amountLabel)

        // Separator view
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -12),

            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    func configure(with transaction: TokenTransaction) {
        descriptionLabel.text = transaction.description

        // Format amount with + or - and color
        let sign = transaction.amount >= 0 ? "+" : ""
        amountLabel.text = "\(sign)\(transaction.amount)"
        amountLabel.textColor = transaction.type == "earn" ? .systemGreen : .systemRed
    }
}
