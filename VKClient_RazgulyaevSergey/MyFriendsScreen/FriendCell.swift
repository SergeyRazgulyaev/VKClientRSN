//
//  FriendCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 09.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var friendAvatar: FriendAvatar!
    @IBOutlet private weak var friendAvatarImageView: UIImageView!

    //MARK: - Configuration Methods
    func configureTitleLabel(titleLabelText: String) {
        titleLabel.text = titleLabelText
    }
    
    func configureFriendAvatarImage(friendAvatarImage: UIImage) {
        friendAvatarImageView.image = friendAvatarImage
    }
    
    //MARK: - IBActions
    @IBAction func friendAvatarTap(_ sender: Any) {
        friendAvatar.avatarTapWithAnimation()
    }
}
