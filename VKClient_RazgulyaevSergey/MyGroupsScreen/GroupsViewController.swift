//
//  GroupsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import RealmSwift
import PromiseKit
import os.log

class GroupsViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    private let networkServicePromise = NetworkServicePromise()
    
    //MARK: - Properties for Interaction with Database
    private var filteredGroupsNotificationToken: NotificationToken?
    private let realmManager = RealmManager.instance
    
    private var groupsFromRealm: Results<GroupItem>? {
        let groupsFromRealm: Results<GroupItem>? = realmManager?.getObjects()
        return groupsFromRealm
    }
    
    private var filteredGroups: Results<GroupItem>? {
        guard !searchText.isEmpty else { return groupsFromRealm }
        return groupsFromRealm?.filter("name CONTAINS[cd] %@", searchText)
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
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        configureTableView()
        createNotification()
        startPromiseChainForGroups()
    }
    
    //MARK: - Deinit filteredGroupsNotificationToken
    deinit {
        filteredGroupsNotificationToken?.invalidate()
    }
    
    //MARK: - Configuration Methods
    func configureSearchBar() {
        searchBar.delegate = self
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
    }
    
    //MARK: - IBActions
    @IBAction func onAddGroupBarButtonPressing(_ sender: Any) {
        let alert = UIAlertController(title: "Добавить группу", message: nil, preferredStyle: .alert)
        alert.addTextField {(textField) in
            textField.placeholder = "Название группы"
        }
        let action = UIAlertAction(title: "Ok", style: .default) { [weak self, weak alert] (action) in
            guard let firstText = alert?.textFields?.first?.text else { return }
            let group = GroupItem()
            group.id = Int.random(in: 0...1_000_000)
            group.name = firstText
            group.photo100 = "https://sun1-14.userapi.com/impg/c858424/v858424322/13a01f/VQIFls1ldJA.jpg?size=100x0&quality=88&crop=0,0,1024,1024&sign=bab3698e77e5a193eacd49380e71e223&c_uniq_tag=OAdCz-KTdGnJTiKadj4wXx_80vVh442NtFY4msmmWxI&ava=1"
            group.screenName = ""
            group.type = ""
            self?.addGroup(newGroup: group)
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func addGroup(newGroup: GroupItem) {
        guard !newGroup.name.isEmpty else { return }
        try? realmManager?.add(object: newGroup)
    }
}

//MARK: - Interaction with Network
extension GroupsViewController {
    func startPromiseChainForGroups() {
        firstly {
            networkServicePromise.loadGroupsPromise(token: Session.instance.token, on: .global())
        }
        .done(on: .main) { [weak self] groups in
            try? self?.realmManager?.add(objects: groups)}
            .catch { error in
                Logger.viewCycle.debug("\(error.localizedDescription)")
        }
        .finally {
            // Groups data is written to the Realm DataBase
        }
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        startPromiseChainForGroups ()
        let alertTitle = "Refresh activated"
        let alertMessage = "Groups Table refreshed"
        showAlert(title: alertTitle, message: alertMessage, completion: { [weak self] in
            self?.refreshControl.endRefreshing()
        })
    }
}

//MARK: - Interaction with Realm Database
extension GroupsViewController {
    private func createNotification() {
        filteredGroupsNotificationToken = filteredGroups?.observe { [weak self] change in
            switch change {
            case let . initial(filteredGroups):
                print("Initialized \(filteredGroups.count)")
                
            case let .update(filteredGroups, deletions: deletions, insertions: insertions, modifications: modifications):
                print("""
                    New count: \(filteredGroups.count)
                    Deletions: \(deletions)
                    Insertions: \(insertions)
                    Modifications: \(modifications)
                    """)
                self?.tableView.reloadData()
                
            case let .error(error):
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

//MARK: - TableView Data Source Methods
extension GroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroups?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(indexPath: indexPath)
    }
    
    func configureCell(indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell") as? GroupCell else {
            return UITableViewCell()
        }
        guard let group = filteredGroups?[indexPath.row] else {
            return cell
        }
        let groupAvatar = group.photo100
        guard let url = URL(string: groupAvatar),
              let data = try? Data(contentsOf: url),
              let groupAvatarImage = (UIImage(data: data)) else {
            return cell
        }
        let titleLabelText = group.name
        cell.configure(titleLabelText: titleLabelText, groupAvatarImage: groupAvatarImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let deletedGroup = filteredGroups?[indexPath.item] else { return }
            try? realmManager?.delete(object: deletedGroup)
        }
    }
}

//MARK: - TableView Delegate Methods
extension GroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

//MARK: - SearchController
extension GroupsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.reloadData()
    }
}

//MARK: - Alert 
extension GroupsViewController {
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
