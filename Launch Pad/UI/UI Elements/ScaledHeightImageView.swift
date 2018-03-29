//
//  ScaledHeightImageView.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 29.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit
import Foundation

class ScaledHeightImageView: NSImageView {

    override var intrinsicContentSize: CGSize {
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width

            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio

            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        return CGSize(width: -1.0, height: -1.0)
    }
}
