//
//  AvailableGroupAvatar.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 24.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class AvailableGroupAvatar: UIControl {
    @IBOutlet private weak var availableGroupAvatarImageView: UIImageView!
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureAvailableGroupAvatar()
        configureGestureRecognizer()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureAvailableGroupAvatar()
    }
    
    //MARK: - Configuration Methods
    func configureAvailableGroupAvatar() {
        layer.cornerRadius = bounds.width / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowPath = UIBezierPath(ovalIn: bounds).cgPath
        
        availableGroupAvatarImageView.layer.cornerRadius = availableGroupAvatarImageView.bounds.width / 2
        availableGroupAvatarImageView.clipsToBounds = true
    }
    
    func configureGestureRecognizer() {
        let availableGroupAvatarTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(availableGroupAvatarTapRecognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        avatarTapAnimation()
        
    }
    
    //MARK: - Animation
    func avatarTapAnimation() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.9
        animation.toValue = 1
        animation.stiffness = 300
        animation.mass = 0.5
        animation.duration = 0.5
        animation.beginTime = CACurrentMediaTime()
        animation.fillMode = CAMediaTimingFillMode.backwards
        
        availableGroupAvatarImageView.layer.add(animation, forKey: nil)
        layer.add(animation, forKey: nil)
    }
}
