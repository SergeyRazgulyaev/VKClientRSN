//
//  AsyncImageView.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 12.10.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import Foundation
import UIKit

class AsyncImageView: UIImageView {
    private var _image: UIImage?

    override var image: UIImage? {
        get {
            return _image
        }
        
        set {
            _image = newValue
            layer.contents = nil
            
            guard let image = newValue else {
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                let decodedCGImage = self.decode(image)
                DispatchQueue.main.async {
                    self.layer.contents = decodedCGImage
                }
            }
        }
    }
    
    private func decode(_ image: UIImage) -> CGImage? {
        // Convert the incoming UIImage to CoreGraphics Image
        guard let newImage = image.cgImage else { return nil }
        
        // Check the Cache for a decoded CGImage
        if let cacheImage = AsyncImageView.cache.object(forKey: image) {
            return (cacheImage as! CGImage)
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: nil,
            width: newImage.width,
            height: newImage.height,
            bitsPerComponent: 8,
            bytesPerRow: newImage.width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        // Calculate CornerRadius for the rounding
        let imageRect = CGRect(
            x: 0,
            y: 0,
            width: newImage.width,
            height: newImage.height
        )
        
        let cornerRadius = UIBezierPath(roundedRect: imageRect, cornerRadius: 70).cgPath
        
        context?.addPath(cornerRadius)
        context?.clip()
        
        // Draw Image into Context
        context?.draw(newImage, in: CGRect(x: 0, y: 0, width: newImage.width, height: newImage.height))
        
        // Check if the CGImage was created successfully
        guard let drawImage = context?.makeImage() else { return nil }
        // If yes, before returning the object, save it to the cache
        AsyncImageView.cache.setObject(drawImage, forKey: image)
        
        return drawImage
    }
}

extension AsyncImageView {
    private struct Cache {
        static var instance = NSCache<AnyObject, AnyObject>()
    }
    class var cache: NSCache<AnyObject, AnyObject> {
        get {
            return Cache.instance
        }
        set {
            Cache.instance = newValue
        }
    }
}
    
