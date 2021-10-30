//
//  SectionHeader.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 20.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class SectionHeader: UITableViewHeaderFooterView {
    @IBOutlet private weak var headerFirstLetterLabel: UILabel!
    
    //MARK: - Configuration Methods
    func configureHeaderFirstLetterLabelText(headerFirstLetterLabelText: String) {
        headerFirstLetterLabel.text = headerFirstLetterLabelText
        tintColor = .white
    }
}
