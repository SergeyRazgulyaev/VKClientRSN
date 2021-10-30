//
//  ZoomPhotoViewController.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 27.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit
import RealmSwift
import os.log

class ZoomPhotoViewController: UIViewController {
    @IBOutlet private weak var zoomedFriendsPhotoImageView: UIImageView!
    @IBOutlet private weak var zoomedNextFriendPhotoImageView: UIImageView!
    
    //MARK: - Base properties
    var friendID: Int?
    var friendZoomPhotoNumber: Int = 1
    private var photoNumbersArray: [Int] = []
    private var previousImage: UIImage? = UIImage(systemName: "tortoise")
    private var shownImage: UIImage? = UIImage(systemName: "hare")
    private var nextImage: UIImage? = UIImage(systemName: "hare")
    private lazy var zoomPhotoIndex: Int = {
        return friendZoomPhotoNumber - 1 
    }()

    //MARK: - Properties for Interaction with Network
    private let networkService = NetworkService()
    
    //MARK: - Properties for Interaction with Database
    private let realmManagerPhotos = RealmManager.instance
    private var oneFriendPhotosFromRealm: Results<PhotoItem>? {
        let oneFriendPhotosFromRealm: Results<PhotoItem>? = realmManagerPhotos?.getObjects().filter("ownerID = \(friendID ?? -1)")
        return oneFriendPhotosFromRealm
    }
    
    //MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestureRecognizer()
        configurePhotoInteraction()
        loadPhotosFromNetWork()
        showZoomPhotos()
    }
}

//MARK: - Interaction with Network
extension ZoomPhotoViewController {
    func loadPhotosFromNetWork() {
        guard friendID != nil else {
            zoomedFriendsPhotoImageView.image = UIImage(systemName: "tortoise")
            return
        }
        networkService.loadPhotos(token: Session.instance.token,
                                  ownerID: friendID ?? 0,
                                  albumID: .profile,
                                  photoCount: 10) { [weak self] result in
            switch result {
            case let .success(photos):
                DispatchQueue.main.async {
                    try? self?.realmManagerPhotos?.add(objects: photos)
                }
            case let .failure(error):
                Logger.viewCycle.debug("\(error.localizedDescription)")
            }
        }
    }
}

//MARK: - Preparation for Display 
extension ZoomPhotoViewController {
    func showZoomPhotos() {
        guard let onePhoto = oneFriendPhotosFromRealm?[zoomPhotoIndex],
              let urlFromRealm = onePhoto.sizes.last?.url,
              let zoomedFriendsPhotoURL = URL(string: urlFromRealm),
              let zoomedFriendsPhotoData = try? Data(contentsOf: zoomedFriendsPhotoURL),
              let photosCount = oneFriendPhotosFromRealm?.count else {
            return
        }
        if (zoomPhotoIndex >= 0) && (zoomPhotoIndex < (photosCount - 1)) {
            guard let oneNextPhoto = oneFriendPhotosFromRealm?[zoomPhotoIndex + 1],
                  let urlFromRealm = oneNextPhoto.sizes.last?.url,
                  let zoomedNextFriendsPhotoURL = URL(string: urlFromRealm),
                  let zoomedNextFriendsPhotoData = try? Data(contentsOf: zoomedNextFriendsPhotoURL) else {
                return
            }
            zoomedFriendsPhotoImageView.image = UIImage(data: zoomedFriendsPhotoData)
            zoomedNextFriendPhotoImageView.image = UIImage(data: zoomedNextFriendsPhotoData)
        } else if zoomPhotoIndex == (photosCount - 1) {
            guard let oneNextPhoto = oneFriendPhotosFromRealm?[0],
                  let urlFromRealm = oneNextPhoto.sizes.last?.url,
                  let zoomedNextFriendsPhotoURL = URL(string: urlFromRealm),
                  let zoomedNextFriendsPhotoData = try? Data(contentsOf: zoomedNextFriendsPhotoURL) else {
                return
            }
            zoomedFriendsPhotoImageView.image = UIImage(data: zoomedFriendsPhotoData)
            zoomedNextFriendPhotoImageView.image = UIImage(data: zoomedNextFriendsPhotoData)
        }
    }
    
    func photoNumbersArrayCreator(photoCount: Int) {
        var tempArray: [Int] = []
        guard photoCount != 0 else {
            return
        }
        for i in 1...photoCount {
            tempArray.append(i)
        }
        photoNumbersArray = tempArray.sorted(by: {$1<$0})
    }
}

//MARK: - Swipe Gesture Recognizer
extension ZoomPhotoViewController {
    func configureGestureRecognizer() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        swipeRight.direction = .right
        zoomedFriendsPhotoImageView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        swipeLeft.direction = .left
        zoomedFriendsPhotoImageView.addGestureRecognizer(swipeLeft)
    }
    
    @objc func swipeGesture(_ sender: UISwipeGestureRecognizer?) {
        if let swipeGesture = sender {
            switch swipeGesture.direction {
            case .right:
                if zoomPhotoIndex > 0 {
                    guard let previousPhoto = oneFriendPhotosFromRealm?[zoomPhotoIndex - 1],
                          let urlFromRealm = previousPhoto.sizes.last?.url,
                          let previousImageURL = URL(string: urlFromRealm),
                          let previousImageData = try? Data(contentsOf: previousImageURL) else {
                        return
                    }
                    guard let shownPhoto = oneFriendPhotosFromRealm?[zoomPhotoIndex],
                          let urlFromRealm = shownPhoto.sizes.last?.url,
                          let shownImageURL = URL(string: urlFromRealm),
                          let shownImageData = try? Data(contentsOf: shownImageURL) else {
                        return
                    }
                    previousImage = UIImage(data: previousImageData)
                    shownImage = UIImage(data: shownImageData)
                    photosReverseAnimation()
                }
            case .left:
                guard let photosCount = oneFriendPhotosFromRealm?.count else {
                    return
                }
                if zoomPhotoIndex != photosCount - 1 {
                    guard let nextPhoto = oneFriendPhotosFromRealm?[zoomPhotoIndex + 1],
                          let urlFromRealm = nextPhoto.sizes.last?.url,
                          let nextImageURL = URL(string: urlFromRealm),
                          let nextImageData = try? Data(contentsOf: nextImageURL) else {
                        return
                    }
                    guard let shownPhoto = oneFriendPhotosFromRealm?[zoomPhotoIndex],
                          let urlFromRealm = shownPhoto.sizes.last?.url,
                          let shownImageURL = URL(string: urlFromRealm),
                          let shownImageData = try? Data(contentsOf: shownImageURL) else {
                        return
                    }
                    nextImage = UIImage(data: nextImageData)
                    shownImage = UIImage(data: shownImageData)
                    photosAnimation()
                }
            default:
                break
            }
        }
    }
}

//MARK: - Animation
extension ZoomPhotoViewController {
    func configurePhotoInteraction() {
        zoomedFriendsPhotoImageView.isUserInteractionEnabled = true
        zoomedNextFriendPhotoImageView.isUserInteractionEnabled = true
    }
 
    func photosAnimation() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.zoomPhotoIndex += 1
        })
        
        zoomedNextFriendPhotoImageView.image = nextImage
        zoomedFriendsPhotoImageView.image = shownImage
        
        let animationTransformScale = CASpringAnimation(keyPath: "transform.scale")
        animationTransformScale.duration = 1
        animationTransformScale.fromValue = 1
        animationTransformScale.toValue = 0.9
        animationTransformScale.stiffness = 100
        animationTransformScale.mass = 0.3
        animationTransformScale.fillMode = CAMediaTimingFillMode.both
        animationTransformScale.isRemovedOnCompletion = false
        zoomedFriendsPhotoImageView.layer.add(animationTransformScale, forKey: nil)
        
        let animationTransform = CABasicAnimation(keyPath: "position.x")
        animationTransform.duration = 1
        animationTransform.fromValue = zoomedNextFriendPhotoImageView.frame.width * 2
        animationTransform.toValue = zoomedNextFriendPhotoImageView.frame.width / 2
        animationTransform.fillMode = CAMediaTimingFillMode.both
        animationTransform.isRemovedOnCompletion = false
        zoomedNextFriendPhotoImageView.layer.add(animationTransform, forKey: nil)
        
        CATransaction.commit()
    }
    
    func photosReverseAnimation() {
        zoomedNextFriendPhotoImageView.image = shownImage
        zoomedFriendsPhotoImageView.image = previousImage
        zoomPhotoIndex -= 1
        
        let animationTransformScale = CASpringAnimation(keyPath: "transform.scale")
        animationTransformScale.duration = 1
        animationTransformScale.fromValue = 0.9
        animationTransformScale.toValue = 1
        animationTransformScale.stiffness = 100
        animationTransformScale.mass = 0.3
        animationTransformScale.fillMode = CAMediaTimingFillMode.both
        animationTransformScale.isRemovedOnCompletion = false
        zoomedFriendsPhotoImageView.layer.add(animationTransformScale, forKey: nil)
        
        let animationTransform = CABasicAnimation(keyPath: "position.x")
        animationTransform.duration = 1
        animationTransform.fromValue = zoomedNextFriendPhotoImageView.frame.width / 2
        animationTransform.toValue = zoomedNextFriendPhotoImageView.frame.width * 2
        animationTransform.fillMode = CAMediaTimingFillMode.both
        animationTransform.isRemovedOnCompletion = false
        zoomedNextFriendPhotoImageView.layer.add(animationTransform, forKey: nil)
    }
}
