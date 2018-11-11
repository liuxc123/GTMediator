//
//  HomeViewController.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, HomeServiceProtocol {
 
    func swiftBundleName() -> String! {
        return "GTMediatorSwift"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        self.title = "HomeViewController"
    }
    
    

}
