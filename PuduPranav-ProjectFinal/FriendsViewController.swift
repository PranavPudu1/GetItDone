// Project: PuduPranav-ProjectFinal
// EID: prp768
// Course: CS329E

import UIKit
import FirebaseAuth

class FriendsViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    private var followedFriends: [FriendUser] = []
    private var suggestedFriends: [FriendUser] = []
    private var followedFriendIds: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        title = "Friends"
        setupTableView()
        setupSearchBar()
        loadSuggestedFriends()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFollowedFriends()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SuggestedFriendCell.self, forCellReuseIdentifier: "SuggestedFriendCell")
        tableView.separatorStyle = .none
        tableView.rowHeight = 70
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search friends..."
    }

    private func loadSuggestedFriends() {
        // Use the first 3 sample users as suggested friends
        // Peyton Manning, Pranav Pudu, Eli Manning
        let users = [
            SampleData.sampleUsers[1], // Peyton Manning
            SampleData.sampleUsers[0], // Pranav Pudu
            SampleData.sampleUsers[2]  // Eli Manning
        ]

        suggestedFriends = users.map { FriendUser(from: $0) }
        tableView.reloadData()
    }

    private func loadFollowedFriends() {
        FirebaseService.shared.fetchFollowedFriendsDetails { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friends):
                    self?.followedFriends = friends
                    self?.followedFriendIds = Set(friends.map { $0.uid })
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error loading followed friends: \(error.localizedDescription)")
                    self?.followedFriends = []
                    self?.followedFriendIds = []
                    self?.tableView.reloadData()
                }
            }
        }
    }

    private func followFriend(_ friend: FriendUser, at indexPath: IndexPath) {
        FirebaseService.shared.followFriend(friend: friend) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.loadFollowedFriends()
                case .failure(let error):
                    print("Error following friend: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Friends and Suggested Friends
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return followedFriends.count
        } else {
            // Filter out already followed friends from suggestions
            return suggestedFriends.filter { !followedFriendIds.contains($0.uid) }.count
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "AppBackground")

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = section == 0 ? "Friends" : "Suggested Friends"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor(named: "AppPrimaryBrown")
        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && followedFriends.isEmpty {
            return 0
        }
        return 44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedFriendCell", for: indexPath) as? SuggestedFriendCell else {
            return UITableViewCell()
        }

        let friend: FriendUser
        let isFollowing: Bool

        if indexPath.section == 0 {
            // Friends section
            friend = followedFriends[indexPath.row]
            isFollowing = true
        } else {
            // Suggested friends section
            let availableSuggestions = suggestedFriends.filter { !followedFriendIds.contains($0.uid) }
            friend = availableSuggestions[indexPath.row]
            isFollowing = false
        }

        cell.configure(with: friend, isFollowing: isFollowing)

        cell.onFollowTapped = { [weak self] in
            self?.followFriend(friend, at: indexPath)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let friend: FriendUser
        if indexPath.section == 0 {
            friend = followedFriends[indexPath.row]
        } else {
            let availableSuggestions = suggestedFriends.filter { !followedFriendIds.contains($0.uid) }
            friend = availableSuggestions[indexPath.row]
        }

        // Find the corresponding UserProfile from sample data
        guard let user = SampleData.sampleUsers.first(where: { $0.uid == friend.uid }) else {
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {
            return
        }

        profileVC.userProfile = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension FriendsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
