//
//  HeartView.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 14.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

class HeartView: UIControl {
    @IBOutlet private weak var heartLabel: UILabel!
    
    //MARK: - Base properties
    private let heartImageView = UIImageView()
    private var image = UIImage()
    private var heartCount: Int = 0
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureHeartView()
        addSubview(heartImageView)
        configureGestureRecognizer()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureHeartView()
    }
    
    //MARK: - Configuration Methods
    func configureHeartView() {
        heartImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        heartImageView.contentMode = .scaleAspectFit
        heartImageView.image = UIImage(named: "HeartNo")
    }
    
    func configureGestureRecognizer() {
        let heartViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(heartViewTapRecognizer)
    }
    
    func configureheartLabel(heartLabelNumber: String) {
        heartLabel.text = heartLabelNumber
    }
    
    @objc func onTap(_ sender: Any?) {
        if heartImageView.image == UIImage(named: "HeartNo") {
            heartImageView.image = UIImage(named: "HeartYes")
            heartCount = Int(heartLabel.text ?? "0") ?? 0
            heartCount += 1
            UIView.transition(with: heartLabel, duration: 0.2, options: .transitionFlipFromRight, animations: {self.heartLabel.text = String(self.heartCount)})
            setNeedsDisplay()
        } else {
            heartImageView.image = UIImage(named: "HeartNo")
            heartCount = Int(heartLabel.text ?? "0") ?? 0
            heartCount -= 1
            UIView.transition(with: heartLabel, duration: 0.2, options: .transitionFlipFromLeft, animations: {self.heartLabel.text = String(self.heartCount)})
            setNeedsDisplay()
        }
    }
}
