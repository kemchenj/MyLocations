//
//  HudView.swift
//  MyLocations
//
//  Created by kemchenj on 6/28/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""

    class func hudInView(view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false

        view.addSubview(hudView)
        view.isUserInteractionEnabled = false

        hudView.backgroundColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 0.5)

        return hudView
    }
}
