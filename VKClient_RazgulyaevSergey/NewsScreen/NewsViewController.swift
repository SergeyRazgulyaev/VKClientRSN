//
//  NewsViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import os.log

class NewsViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Base properties
    private var dateTextCache: [IndexPath : String] = [:]
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = DateFormatter.Style.long
        return df
    }()
    private var sourceIDChecker: Int = 0
    
    //MARK: - Cell properties
    private let newsPostCellIdentifier = "NewsPostCellIdentifier"
    private let newsPostCellNibName = "NewsPostCell"
    private let newsPhotoCellIdentifier = "NewsPhotoCellIdentifier"
    private let newsPhotoCellNibName = "NewsPhotoCell"
    
    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    private var newsFromNetwork: NewsResponse?
    private var nextFrom = ""
    private var isLoading = false
    
    //MARK: - Properties for RefreshController
    private lazy var refreshControl = UIRefreshControl()
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupRefreshControl()
        loadPostNewsFromNetwork()
    }
    
    //MARK: - Configuration Methods
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.prefetchDataSource = self
        tableView.register(UINib(nibName: newsPostCellNibName, bundle: nil), forCellReuseIdentifier: newsPostCellIdentifier)
    }
    
}

//MARK: - Refresh Method (Pull-to-refresh Pattern)
extension NewsViewController {
    fileprivate func setupRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh News...", attributes: [.font: UIFont.systemFont(ofSize: 10)])
        refreshControl.tintColor = .systemGreen
        refreshControl.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
    }
    
    @objc private func refreshNews() {
        self.refreshControl.beginRefreshing()
        let mostFreshNewsDate = self.newsFromNetwork?.items.first?.date ?? Date().timeIntervalSince1970
        networkService.loadNews(
            token: Session.instance.token,
            typeOfNews: .post,
            startTime: (mostFreshNewsDate + 1),
            startFrom: ""
        ) { [weak self] result in
            switch result {
            case let .success(refreshedNews):
                DispatchQueue.main.async {
                    guard refreshedNews.items.count > 0 else { return }
                    self?.newsFromNetwork?.items = refreshedNews.items + (self?.newsFromNetwork?.items ?? [])
                    self?.newsFromNetwork?.groups = refreshedNews.groups + (self?.newsFromNetwork?.groups ?? [])
                    self?.newsFromNetwork?.profiles = refreshedNews.profiles + (self?.newsFromNetwork?.profiles ?? [])
                    let indexPathes = refreshedNews.items.enumerated().map { offset, element in
                        IndexPath(row: offset, section: 0)
                    }
                    self?.tableView.insertRows(at: indexPathes, with: .automatic)
                }
            case let .failure(error):
                Logger.viewCycle.debug("\(error.localizedDescription)")
            }
        }
        self.refreshControl.endRefreshing()
    }
}

//MARK: - Interaction with Network
extension NewsViewController {
    func loadPostNewsFromNetwork(completion: (() -> Void)? = nil) {
        networkService.loadNews(token: Session.instance.token, typeOfNews: .post, startTime: nil, startFrom: "") { [weak self] result in
            switch result {
            case let .success(news):
                DispatchQueue.main.async {
                    self?.newsFromNetwork = news
                    self?.tableView.reloadData()
                    completion?()
                }
            case let .failure(error):
                Logger.viewCycle.debug("\(error.localizedDescription)")
            }
        }
    }
}


//MARK: - TableView Data Source Prefetching Methods
extension NewsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard indexPaths.contains(where: isLoadingCell(for:)) else { return }
        networkService.loadNews(token: Session.instance.token, typeOfNews: .post, startTime: nil, startFrom: Session.instance.newsNextFrom) { [weak self] result in
            switch result {
            case let .success(prefetchedPostNews):
                DispatchQueue.main.async {
                    guard prefetchedPostNews.items.count > 0 else { return }
                    self?.newsFromNetwork?.items = (self?.newsFromNetwork?.items ?? []) + (prefetchedPostNews.items)
                    self?.newsFromNetwork?.groups = (self?.newsFromNetwork?.groups ?? []) + (prefetchedPostNews.groups)
                    self?.newsFromNetwork?.profiles = (self?.newsFromNetwork?.profiles ?? []) + (prefetchedPostNews.profiles)
                    self?.tableView.reloadData()
                }
            case let .failure(error):
                Logger.viewCycle.debug("\(error.localizedDescription)")
            }
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        let newsCount = self.newsFromNetwork?.items.count ?? 0
        return indexPath.row == newsCount - 3
    }
}

//MARK: - TableView Data Source Methods
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFromNetwork?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureNewsCell(indexPath: indexPath)
    }
    
    func configureNewsCell(indexPath: IndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCell(withIdentifier: newsPostCellIdentifier, for: indexPath) as? NewsPostCell
        guard let cell = newsCell, let news = newsFromNetwork else {
            return UITableViewCell() // If error with News Cell
        }
        
        // Triggering of button "Show more ... hide" in the Cell
        cell.postTextShowButtonAction = {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        // Configure News Likes, Comments, Shares, Views
        cell.newsLikeIndicator.configureNewsLikeLabelText(newsLikeLabelText: String(news.items[indexPath.row].likes.count))
        cell.newsCommentIndicator.configureNewsCommentLabelText(newsCommentLabelText: String(news.items[indexPath.row].comments.count))
        cell.newsShareIndicator.configureNewsShareLabelText(newsShareLabelText: String(news.items[indexPath.row].reposts.count))
        cell.newsViewsIndicator.configureNewsViewsLabelText(newsViewsLabelText: String(news.items[indexPath.row].views.count))
        
        // News Source Checker (Friends or Groups)
        sourceIDChecker = news.items[indexPath.row].sourceID
        let groupOwner = news.groups.filter { $0.id == (-sourceIDChecker) }.first
        let friendOwner = news.profiles.filter { $0.id == sourceIDChecker }.first

        // Filling the Cell depending on the News Source
        switch sourceIDChecker {
        case (-Int.max ..< 0): // Groups Cell
            cell.configureNewsAuthorNameLabelText(newsAuthorNameLabelText: groupOwner?.name ?? "")
            cell.comfigureOriginalPostTextHeight(postTextHeight: 95)
            let newsPostSourceAvatarImage = groupOwner?.photo100 ?? ""
            guard let newsPostSourceAvatarImageURL = URL(string: newsPostSourceAvatarImage),
                  let newsPostSourceAvatarImageData = try? Data(contentsOf: newsPostSourceAvatarImageURL),
                  let newsForMeAvatarImage = UIImage(data: newsPostSourceAvatarImageData) else {
                return cell
            }
            cell.configureNewsForMeAvatarImageView(newsForMeAvatarImage: newsForMeAvatarImage)
            
            let postText = news.items[indexPath.row].text ?? ""
            cell.configureNewsDateLabelText(newsDateLabelText: getCellDateText(forIndexPath: indexPath, andTimeToTranslate: Double(news.items[indexPath.row].date)))
            cell.configurePostTextLabelText(postTextLabelText: postText)
            
            guard let mainAttachmentsPath = news.items[indexPath.row].newsAttachments, let typeOfNewsPost = mainAttachmentsPath.first?.type else {
                cell.configureNewsForMeImage(newsForMeImage: UIImage(), photoHeight: 0)
                return cell
            }
            typeOfNewsPostPhotoSwitcher(mainAttachmentsPath: mainAttachmentsPath, typeOfNewsPost: typeOfNewsPost, cell: cell)
            return cell
            
        case (1 ... Int.max): // Friends Cell
            cell.configureNewsAuthorNameLabelText(newsAuthorNameLabelText:(friendOwner?.firstName ?? "") + (" ") + (friendOwner?.lastName ?? ""))
            
            let newsPostSourceAvatarImage = friendOwner?.photo100 ?? ""
            guard let newsPostSourceAvatarImageURL = URL(string: newsPostSourceAvatarImage),
                  let newsPostSourceAvatarImageData = try? Data(contentsOf: newsPostSourceAvatarImageURL),
                  let newsForMeAvatarImage = UIImage(data: newsPostSourceAvatarImageData) else {
                return cell
            }
            cell.configureNewsForMeAvatarImageView(newsForMeAvatarImage: newsForMeAvatarImage)
            
            // Checking for any Data in NewsCopyHistory
            guard news.items[indexPath.row].newsCopyHistory?.count ?? 0 > 0 else {
                // In the absence of any Data in NewsCopyHistory
                let postText = news.items[indexPath.row].text ?? ""
                cell.configurePostTextLabelText(postTextLabelText: postText)
                cell.configureNewsDateLabelText(newsDateLabelText: getCellDateText(forIndexPath: indexPath, andTimeToTranslate: Double(news.items[indexPath.row].date)))
                
                guard let mainAttachmentsPath = news.items[indexPath.row].newsAttachments, let typeOfNewsPost = mainAttachmentsPath.first?.type else {
                    cell.configureNewsForMeImage(newsForMeImage: UIImage(), photoHeight: 0)
                    return cell
                }
                typeOfNewsPostPhotoSwitcher(mainAttachmentsPath: mainAttachmentsPath, typeOfNewsPost: typeOfNewsPost, cell: cell)
                return cell
            }
            // If there is any Data in NewsCopyHistory
            let postText = news.items[indexPath.row].newsCopyHistory?.first?.text ?? ""
            cell.configurePostTextLabelText(postTextLabelText: postText)
            cell.configureNewsDateLabelText(newsDateLabelText: getCellDateText(forIndexPath: indexPath, andTimeToTranslate: Double(news.items[indexPath.row].newsCopyHistory?.first?.date ?? 0)))
            
            guard let mainAttachmentsPath = news.items[indexPath.row].newsCopyHistory?.first?.newsAttachments, let typeOfNewsPost = mainAttachmentsPath.first?.type else {
                cell.configureNewsForMeImage(newsForMeImage: UIImage(), photoHeight: 0)
                return cell
            }
            typeOfNewsPostPhotoSwitcher(mainAttachmentsPath: mainAttachmentsPath, typeOfNewsPost: typeOfNewsPost, cell: cell)
            return cell
            
        default:
            return cell
        }
    }
    
    func newsPostCellFormation(pathForPhoto: NewsAttachmentsPhotoAndVideoSizes, cell: NewsPostCell) {
        var photoRatio: CGFloat = 1.0
        guard let photoWidth = pathForPhoto.width, let photoHeight = pathForPhoto.height else { cell.configureNewsForMeImage(newsForMeImage: UIImage(), photoHeight: 0)
            return }
        if photoHeight != 0 {
            photoRatio = CGFloat(photoWidth) / CGFloat(photoHeight)
        }
        let calculatedPhotoHeight = tableView.frame.width / photoRatio
        let newsPostPhoto = pathForPhoto.url ?? ""
        guard let url = URL(string: newsPostPhoto),
              let data = try? Data(contentsOf: url),
              let newsForMeImage = UIImage(data: data)
              else { return }
        cell.configureNewsForMeImage(newsForMeImage: newsForMeImage, photoHeight: calculatedPhotoHeight)
        return
    }
    
    func typeOfNewsPostPhotoSwitcher(mainAttachmentsPath: [NewsAttachments], typeOfNewsPost: String, cell: NewsPostCell) {
        switch typeOfNewsPost {
        case "link": // Cell formation depending on the Post Type (if Link)
            guard let pathForPhoto = mainAttachmentsPath[0].link?.photo?.sizes.first else {
                cell.configureNewsForMeImage(newsForMeImage: UIImage(), photoHeight: 0)
                return
            }
            newsPostCellFormation(pathForPhoto: pathForPhoto, cell: cell)
        case "photo": // Cell formation depending on the Post Type (if Photo)
            guard let pathForPhoto = mainAttachmentsPath.first?.photo?.sizes.last else {
                cell.configureNewsForMeImage(newsForMeImage: UIImage(), photoHeight: 0)
                return
            }
            newsPostCellFormation(pathForPhoto: pathForPhoto, cell: cell)
        case "video": // Cell formation depending on the Post Type (if Video)
            guard let pathForPhoto = mainAttachmentsPath.first?.video?.image?.last else {
                cell.configureNewsForMeImage(newsForMeImage: UIImage(), photoHeight: 0)
                return
            }
            newsPostCellFormation(pathForPhoto: pathForPhoto, cell: cell)
        default:
            return
        }
    }
}

//MARK: - TableView Delegate Methods
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - Method for translating and caching Dates
extension NewsViewController {
    func getCellDateText(forIndexPath indexPath: IndexPath, andTimeToTranslate timeToTranslate: Double) -> String {
        if let stringDate = dateTextCache[indexPath] {
            return stringDate
        } else {
            let date = Date(timeIntervalSince1970: timeToTranslate)
            let localDate = dateFormatter.string(from: date)
            dateTextCache[indexPath] = localDate
            return localDate
        }
    }
}

//MARK: - Alert
extension NewsViewController {
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
