//
//  AvailableGroupCell.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 10.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class AvailableGroupCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var availableGroupsAvatarImageView: UIImageView!
    @IBOutlet private(set) weak var availableGroupsAvatar: AvailableGroupAvatar!
    
    //MARK: - Configuration Methods
    func configure(titleLabelText: String, availableGroupsAvatarImage: UIImage) {
        titleLabel.text = titleLabelText
        availableGroupsAvatarImageView.image = availableGroupsAvatarImage
    }
}
