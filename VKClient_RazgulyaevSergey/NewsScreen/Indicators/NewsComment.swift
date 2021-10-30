//
//  NewsComment.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsComment: UIControl {
    @IBOutlet private weak var newsCommentLabel: UILabel!
    
    //MARK: - Base properties
    private let newsCommentImage = UIImageView()
    private var image = UIImage()
    private var newsCommentCount: Int = Int.random(in: 0...1000)
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureNewsComment()
        addSubview(newsCommentImage)
        configureGestureRecognizer()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureNewsComment()
    }
    
    //MARK: - Configuration Methods
    func configureNewsComment() {
        newsCommentImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        newsCommentImage.contentMode = .scaleAspectFit
        newsCommentImage.image = UIImage(systemName: "text.bubble")
        newsCommentImage.tintColor = .gray
        newsCommentLabel.text = "\(newsCommentCount)"
    }
    
    func configureGestureRecognizer() {
        let newsCommentTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(newsCommentTapRecognizer)
    }
    @objc func onTap(_ sender: Any?) {}
    
    func configureNewsCommentLabelText(newsCommentLabelText: String) {
        newsCommentLabel.text = newsCommentLabelText
    }
}


