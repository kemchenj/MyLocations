//
//  ShowHud.swift
//  MyLocations
//
//  Created by kemchenj on 6/28/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

protocol Hud {
    var hudText: NSString {set get}

    func showHudInView(rootView view: UIView, animated: Bool)
}

extension Hud where Self: UIViewController {

    func showHudInView(rootView view: UIView, animated: Bool) {
        let hudView = HudView.hudInView("Tagged", animated: true)

        view.addSubview(hudView)
        view.userInteractionEnabled = false
    }



}
