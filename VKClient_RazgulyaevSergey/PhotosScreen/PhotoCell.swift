//
//  PhotoCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet private weak var photosViewController: UIViewController!
    @IBOutlet private weak var photoCardImageView: UIImageView!
    @IBOutlet private weak var photoNumberLabel: UILabel!
    @IBOutlet private weak var photoDateLabel: UILabel!
    @IBOutlet private weak var friendNameLabel: UILabel!
    @IBOutlet private(set) weak var heartView: HeartView!
    
    //MARK: - Base properties
    var userID: Int?
    var interactiveAnimator: UIViewPropertyAnimator!
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configurePhotoCell()
        configureGestureRecognizer()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configurePhotoCell()
    }
    
    //MARK: - Configuration Methods
    func configurePhotoCell() {
        photoCardImageView.isUserInteractionEnabled = true
    }
    
    func configureGestureRecognizer() {
        let photoCardImageViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(photoCardImageViewTapRecognizer)
    }

    @objc func onTap(_ sender: Any?) {
        photosViewController.shouldPerformSegue(withIdentifier: "zoomPhotoSegue", sender: Any?.self)
        let vc = photosViewController.storyboard?.instantiateViewController(withIdentifier: "ZoomPhotoVC") as! ZoomPhotoViewController
        
        vc.friendZoomPhotoNumber = Int(photoNumberLabel.text ?? "1") ?? 1
        vc.friendID = userID
        vc.transitioningDelegate = photosViewController as? UIViewControllerTransitioningDelegate
        photosViewController.navigationController?.delegate = photosViewController as? UINavigationControllerDelegate
        photosViewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureCellUI(photoCardImage: UIImage, photoNumberLabelText: String, photoDateLabelText: String) {
        photoCardImageView.image = photoCardImage
        photoNumberLabel.text = photoNumberLabelText
        photoDateLabel.text = photoDateLabelText
    }
}
