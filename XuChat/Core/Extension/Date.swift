//
//  Date.swift
//  XuChat
//
//  Created by Ercan on 22.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import Foundation

extension Date {
    
    func get(_ type: Calendar.Component)-> String {
        let calendar = Calendar.current
        let t = calendar.component(type, from: self)
        return (t < 10 ? "0\(t)" : t.description)
    }
    
}
