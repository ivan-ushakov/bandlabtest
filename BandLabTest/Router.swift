//
//  Router.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 14/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import UIKit

class Router {
    
    private let window: UIWindow
    
    private var parent: UINavigationController?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func present(_ viewModel: MainViewModel) {
        self.window.rootViewController = MainViewController(viewModel)
        self.window.makeKeyAndVisible()
    }
}
