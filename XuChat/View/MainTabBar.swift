//
//  MainTabBar.swift
//  XuChat
//
//  Created by Ercan on 5.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit

class MainTabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

}
