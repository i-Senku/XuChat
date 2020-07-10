//
//  Bool.swift
//  XuChat
//
//  Created by Ercan on 10.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import Foundation

extension Bool: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = value != 0
    }
}
