//
//  NewsShare.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsShare: UIControl {
    @IBOutlet private weak var newsShareLabel: UILabel!
    
    //MARK: - Base properties
    private let newsShareImage = UIImageView()
    private var image = UIImage()
    private var newsShareCount: Int = Int.random(in: 0...1000)
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureNewsShare()
        addSubview(newsShareImage)
        configureGestureRecognizer()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureNewsShare()
    }
    
    //MARK: - Configuration Methods
    func configureNewsShare() {
        newsShareImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        newsShareImage.contentMode = .scaleAspectFit
        newsShareImage.image = UIImage(systemName: "arrowshape.turn.up.right")
        newsShareImage.tintColor = .gray
        newsShareLabel.text = "\(newsShareCount)"
    }
    
    func configureGestureRecognizer() {
        let newsShareTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(newsShareTapRecognizer)
    }
    @objc func onTap(_ sender: Any?) {}
    
    func configureNewsShareLabelText(newsShareLabelText: String) {
        newsShareLabel.text = newsShareLabelText
    }
}


