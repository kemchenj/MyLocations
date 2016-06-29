//
//  HudView.swift
//  MyLocations
//
//  Created by kemchenj on 6/28/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit


class HudView: UIView {

    var text: NSString!

    static let sharedInstance = HudView()
    private init() {
        super.init(frame: UIScreen.mainScreen().bounds)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("HudView is an Singleton")
    }

    class func hudInView(text: NSString, animated: Bool) -> HudView {
        let hudView = HudView.sharedInstance
        hudView.text = text

        hudView.opaque = false
        hudView.backgroundColor = UIColor(white: 0, alpha: 0.3)

        hudView.showAnimated()

        return hudView
    }

    private func showAnimated() {

        alpha = 0
        transform = CGAffineTransformMakeScale(1.3, 1.3)

        UIView.animateWithDuration(0.3) {
            self.alpha = 1
            self.transform = CGAffineTransformIdentity
        }
    }

    override func drawRect(rect: CGRect) {

        let boxWidth: CGFloat = 96
        let boxHieght: CGFloat = 96


        // Draw Container
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2),
                             y: round((bounds.size.height - boxHieght) / 2),
                             width: boxWidth,
                             height: boxHieght)

        let roundedRect = UIBezierPath(roundedRect: boxRect,
                                       cornerRadius: 10)
        UIColor(white: 0, alpha: 0.7).setFill()
        roundedRect.fill()


        // Draw Image
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHieght / 8
            )

            image.drawAtPoint(imagePoint)
        }


        // Draw Text
        let attributes = [ NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor.whiteColor()]
        let textSize = text.sizeWithAttributes(attributes)

        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHieght / 4
        )
        text.drawAtPoint(textPoint, withAttributes: attributes)
    }
    
}
