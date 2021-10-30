//
//  NSStringExtensions.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 08.10.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import UIKit

extension NSString {
    func getBoundingRect(textBlock: CGSize, font: UIFont) -> CGRect {
        let rect = boundingRect(
            with: textBlock,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font : font],
            context: nil)
        return rect
    }
}
