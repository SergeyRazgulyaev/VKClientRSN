//
//  FriendsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire

class FriendsViewController: UIViewController, UITableViewDelegate {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Base properties
    private var setWithFirstLettersOfFriendsName: Set<String> = []
    private var arrayWithFirstLettersOfFriendsName: [String] = []
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    private let myOperationQueue = OperationQueue()
    
    //MARK: - Properties for Interaction with Database
    private var friendsFromRealmDBNotificationToken: NotificationToken?
    private let realmManager = RealmManager.instance
    
    private var friendsFromRealmDB: Results<UserItem>? {
        guard searchText.isEmpty else {
            return realmManager?.getObjects().filter("firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", searchText, searchText)
        }
        return realmManager?.getObjects()
    }
    
    //MARK: - Properties for SearchController
    private var searchText: String {
        searchBar.text ?? ""
    }
    private var isFiltering: Bool {
        return !searchText.isEmpty
    }
    
    //MARK: - Properties for RefreshController
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemGreen
        refreshControl.attributedTitle = NSAttributedString(string: "Reload Data", attributes: [.font: UIFont.systemFont(ofSize: 10)])
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        loadFriendsFromNetWork { [weak self] in
            self?.refreshControl.endRefreshing()
        }
        arrayWithFirstLettersOfFriendsNameCreation()
    }
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureTableView()
        createNotification()
        loadFriendsFromNetWorkIfNeeded()
    }
    
    //MARK: - Deinit friendsFromRealmDBNotificationToken
    deinit {
        friendsFromRealmDBNotificationToken?.invalidate()
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "photosSegue",
           let cell = sender as? FriendCell,
           let destination = segue.destination as? PhotosViewController {
            destination.name = cell.titleLabel.text
            destination.friendID = cell.friendAvatar.userID
        }
    }
    
    //MARK: - Configuration Methods
    func configureSearchBar() {
        searchBar.delegate = self
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        
        let view = UIView()
        view.frame = .init(x: 0, y: 0, width: 0, height: 30)
        tableView.tableHeaderView = view
        tableView.register(UINib(nibName: "SectionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerFirstLetter")
    }
}

//MARK: - Interaction with Network
extension FriendsViewController {
    func loadFriendsFromNetWorkIfNeeded() {
        guard let friends = friendsFromRealmDB, friends.isEmpty else {
            return arrayWithFirstLettersOfFriendsNameCreation()
        }
        loadFriendsFromNetWork()
    }
    
    func loadFriendsFromNetWork(completion: (() -> Void)? = nil) {
        let request = NetworkService.sessionAF.request("https://api.vk.com/method/friends.get", method: .get, parameters: ["access_token": Session.instance.token, "order": "name", "fields": ["nickname", "sex", "bdate", "city", "photo_100"], "v": "5.124"])
        
        let ​getFriendsDataOperation​ = ​GetDataOperation​(request: request)
        myOperationQueue.addOperation(​getFriendsDataOperation​)
        
        let parseData = ParseFriendsData()
        parseData.addDependency(​getFriendsDataOperation​)
        myOperationQueue.addOperation(parseData)
        
        let reloadTableOfFriendsViewController = ReloadTableOfFriendsViewController(controller: self)
        reloadTableOfFriendsViewController.addDependency(parseData)
        OperationQueue.main.addOperation(reloadTableOfFriendsViewController)
        completion?()
    }
}

//MARK: - Interaction with Realm Database
extension FriendsViewController {
    private func createNotification() {
        friendsFromRealmDBNotificationToken = friendsFromRealmDB?.observe { [weak self] change in
            switch change {
            case let . initial(filteredFriends):
                print("Initialized \(filteredFriends.count)")
                
            case let .update(filteredFriends, deletions: deletions, insertions: insertions, modifications: modifications):
                print("""
                    New count: \(filteredFriends.count)
                    Deletions: \(deletions)
                    Insertions: \(insertions)
                    Modifications: \(modifications)
                    """)
                self?.arrayWithFirstLettersOfFriendsNameCreation()
                self?.tableView.reloadData()
                
            case let .error(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func writeFriendsFromNetworkToRealm(writedObjects: [UserItem]) {
        try? realmManager?.add(objects: writedObjects)
        tableView.reloadData()
    }
    
    func friendsForSectionByFirstLetter(arrayWithFirstLettersOfFriendsName: [String],
                                        section: Int) -> Results<UserItem>? {
        let friendsForSection: Results<UserItem>? = friendsFromRealmDB?.filter("firstName BEGINSWITH '\(arrayWithFirstLettersOfFriendsName[section])'")
        return friendsForSection
    }
}

//MARK: - TableView Data Source Methods
extension FriendsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayWithFirstLettersOfFriendsName.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let friendsForSection = friendsForSectionByFirstLetter(arrayWithFirstLettersOfFriendsName: arrayWithFirstLettersOfFriendsName, section: section)
        return friendsForSection?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(indexPath: indexPath)
    }
    
    private func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as? FriendCell else { return UITableViewCell() }
        let friendsForSection = friendsForSectionByFirstLetter(arrayWithFirstLettersOfFriendsName: arrayWithFirstLettersOfFriendsName, section: indexPath.section)
        if let friend = friendsForSection?[indexPath.row] {
            cell.friendAvatar.configureUserID(userID: friend.id)
            cell.configureTitleLabel(titleLabelText: String("\(friend.firstName) \(friend.lastName)"))
            if let url = URL(string: friend.photo100),
               let data = try? Data(contentsOf: url),
               let friendAvatarImage = UIImage(data: data) {
                cell.configureFriendAvatarImage(friendAvatarImage: friendAvatarImage)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let friendsForSection = friendsForSectionByFirstLetter(arrayWithFirstLettersOfFriendsName: arrayWithFirstLettersOfFriendsName, section: indexPath.section) {
                try? realmManager?.delete(object: friendsForSection[indexPath.item])
            }
        }
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard arrayWithFirstLettersOfFriendsName.count > 0,
              tableView.numberOfRows(inSection: section) != 0,
              let firstLetter = arrayWithFirstLettersOfFriendsName[section].first else {
            return UIView()
        }
        let headerName = String(firstLetter)
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerFirstLetter") as? SectionHeader else { return UIView() }
        header.configureHeaderFirstLetterLabelText(headerFirstLetterLabelText: headerName)
        return header
    }
}

//MARK: - Preparing Data for display
extension FriendsViewController {
    func arrayWithFirstLettersOfFriendsNameCreation() {
        guard let friendsFromRealmDB = friendsFromRealmDB,
              friendsFromRealmDB.count > 0 else {
            return // If network error
        }
        setWithFirstLettersOfFriendsName = []
        arrayWithFirstLettersOfFriendsName = []
        for friend in friendsFromRealmDB {
            setWithFirstLettersOfFriendsName.insert(String(friend.firstName.first!))
        }
        arrayWithFirstLettersOfFriendsName = setWithFirstLettersOfFriendsName.sorted()
    }
}

//MARK: - SearchController
extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        arrayWithFirstLettersOfFriendsNameCreation()
        tableView.reloadData()
    }
}

//MARK: - Alert
extension FriendsViewController {
    private func showAlert(title: String? = nil,
                           message: String? = nil,
                           handler: ((UIAlertAction) -> ())? = nil,
                           completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: completion)
    }
}
