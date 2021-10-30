//
//  NewsLike.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsLike: UIControl {
    @IBOutlet private weak var newsLikeLabel: UILabel!
    
    //MARK: - Base properties
    private let newsLikeImage = UIImageView()
    private var image = UIImage()
    private var newsLikeCount: Int = Int.random(in: 0...50)
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureNewsLike()
        addSubview(newsLikeImage)
        configureGestureRecognizer()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureNewsLike()
    }
    
    //MARK: - Configuration Methods
    func configureNewsLike() {
        newsLikeImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        newsLikeImage.contentMode = .scaleAspectFit
        newsLikeImage.image = UIImage(named: "HeartNo")
        newsLikeLabel.text = String(newsLikeCount)
    }
    
    func configureGestureRecognizer() {
        let newsLikeTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(newsLikeTapRecognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        if newsLikeImage.image == UIImage(named: "HeartNo") {
            newsLikeImage.image = UIImage(named: "HeartYes")
            newsLikeCount = Int(newsLikeLabel.text ?? "0") ?? 0
            newsLikeCount += 1
            UIView.transition(with: newsLikeLabel, duration: 0.2, options: .transitionFlipFromRight, animations: {self.newsLikeLabel.text = String(self.newsLikeCount)})
            setNeedsDisplay()
        } else {
            newsLikeImage.image = UIImage(named: "HeartNo")
            newsLikeCount = Int(newsLikeLabel.text ?? "0") ?? 0
            newsLikeCount -= 1
            UIView.transition(with: newsLikeLabel, duration: 0.2, options: .transitionFlipFromLeft, animations: {self.newsLikeLabel.text = String(self.newsLikeCount)})
            setNeedsDisplay()
        }
    }
    
    func configureNewsLikeLabelText(newsLikeLabelText: String) {
        newsLikeLabel.text = newsLikeLabelText
    }
}
