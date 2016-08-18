//
//  String+AddText.swift
//  MyLocations
//
//  Created by kemchenj on 7/9/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import Foundation

extension String {

    mutating func add(_ text: String?, withSeperator seperator: String = "") {
        if let text = text {
            if isEmpty {
                self += seperator
            }
            self += text
        }
    }
}
