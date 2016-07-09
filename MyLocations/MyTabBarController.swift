//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by kemchenj on 7/9/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    // 返回nil的话tab bar controller会根据自己的status bar style去显示
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
}