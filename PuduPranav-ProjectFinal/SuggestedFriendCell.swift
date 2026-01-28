// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit

class SuggestedFriendCell: UITableViewCell {

    let avatarLabel = UILabel()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let followButton = UIButton()

    var onFollowTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // Avatar circle
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarLabel.textAlignment = .center
        avatarLabel.font = UIFont.boldSystemFont(ofSize: 20)
        avatarLabel.textColor = .white
        avatarLabel.backgroundColor = UIColor(named: "AppPrimaryBrown")
        avatarLabel.layer.cornerRadius = 25
        avatarLabel.clipsToBounds = true
        contentView.addSubview(avatarLabel)

        // Name label
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = UIColor(named: "AppPrimaryBrown")
        contentView.addSubview(nameLabel)

        // Username label
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = UIFont.systemFont(ofSize: 14)
        usernameLabel.textColor = .gray
        contentView.addSubview(usernameLabel)

        // Follow button
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(.white, for: .normal)
        followButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        followButton.layer.cornerRadius = 8
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
        contentView.addSubview(followButton)

        NSLayoutConstraint.activate([
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarLabel.widthAnchor.constraint(equalToConstant: 50),
            avatarLabel.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),

            usernameLabel.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 12),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),
            usernameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 90),
            followButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func followButtonTapped() {
        onFollowTapped?()
    }

    func configure(with friend: FriendUser, isFollowing: Bool) {
        let initial = friend.name.first.map { String($0) } ?? "?"
        avatarLabel.text = initial
        nameLabel.text = friend.name
        usernameLabel.text = "@\(friend.username)"

        if isFollowing {
            followButton.setTitle("Following", for: .normal)
            followButton.backgroundColor = .systemGray
            followButton.isEnabled = false
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.backgroundColor = UIColor(named: "AppPrimaryBrown")
            followButton.isEnabled = true
        }
    }
}
