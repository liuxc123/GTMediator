//
//  ViewController.swift
//  GTMediatorSwift
//
//  Created by liuxc on 2018/11/10.
//  Copyright © 2018 liuxc123. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "首页"
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            let url = URL(string: "com.liuxc.GTMediatorSwift://jump.vc.beehive/HomeViewController")
            GTRouter.open(url)
        }
    }


}

