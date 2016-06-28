//
//  HudView.swift
//  MyLocations
//
//  Created by kemchenj on 6/28/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

protocol Hud {
    var text: NSString {set get}
    var hudView: UIView? {set get}

    func showAnimated(view: UIView, animated: Bool)
    func showHudInView(view: UIView, animated: Bool)
}

extension Hud where Self: UIViewController {

    mutating func showHudInView(view: UIView, animated: Bool) {
        hudView = UIView(frame: view.bounds)
        hudView!.isOpaque = false

        view.addSubview(hudView!)
        view.isUserInteractionEnabled = false
        
        hudView!.backgroundColor = UIColor(white: 0, alpha: 0.3)
        
        showAnimated(view: hudView!, animated: animated)
    }

    private func showAnimated(view: UIView, animated: Bool) {
        if animated {
            hudView!.alpha = 0
            hudView!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

            UIView.animate(withDuration: 0.3) {
                self.hudView!.alpha = 1
                self.hudView!.transform = CGAffineTransform.identity
            }
        }
    }
}

class hud: <#super class#> {
    <#code#>
}{
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHieght: CGFloat = 96

        // Draw Container
        let boxRect = CGRect(x: round((self.bounds.size.width - boxWidth) / 2),
                             y: round((self.bounds.size.height - boxHieght) / 2),
                             width: boxWidth,
                             height: boxHieght)

        let roundedRect = UIBezierPath(roundedRect: boxRect,
                                       cornerRadius: 10)
        UIColor(white: 0, alpha: 0.7).setFill()
        roundedRect.fill()


        // Draw Image
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: self.center.x - round(image.size.width / 2),
                y: self.center.y - round(image.size.height / 2) - boxHieght / 8
            )

            image.draw(at: imagePoint)
        }


        // Draw Text
        let attributes = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                           NSForegroundColorAttributeName: UIColor.white()]
        let textSize = text.size(attributes: attributes)

        let textPoint = CGPoint(
            x: hudView!.center.x - round(textSize.width / 2),
            y: hudView!.center.y - round(textSize.height / 2) + boxHieght / 4
        )
        text.draw(at: textPoint, withAttributes: attributes)
    }

}
