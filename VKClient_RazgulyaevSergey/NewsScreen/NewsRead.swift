//
//  NewsViews.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class NewsViews: UIView {
    @IBOutlet weak var newsReadLabel: UILabel!
    
    let newsReadImage = UIImageView()
    var image = UIImage()
    var newsReadCount: Int = Int.random(in: 0...1000)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configure()
    }
    
    func configure() {
        newsReadImage.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        newsReadImage.contentMode = .scaleAspectFit
        addSubview(newsReadImage)
        newsReadImage.image = UIImage(systemName: "eye")
        newsReadImage.tintColor = .gray
        newsReadLabel.text = "\(newsReadCount)"
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(recognizer)
    }
    
    @objc func onTap(_ sender: Any?) {
        print("Comment on news tapped")
    }
}

