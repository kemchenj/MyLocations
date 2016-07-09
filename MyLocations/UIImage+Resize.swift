//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by kemchenj on 7/9/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

extension UIImage {
    func resizedImage(with bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPointZero, size: newSize))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
