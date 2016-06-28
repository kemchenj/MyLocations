//
//  Functions.swift
//  MyLocations
//
//  Created by kemchenj on 6/28/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(seconds: Double, closure: () -> ()) {
    let when: DispatchTime = .now() + seconds
    DispatchQueue.main.after(when: when, execute: closure)
}
