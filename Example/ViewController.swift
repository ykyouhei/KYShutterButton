//
//  ViewController.swift
//  Example
//
//  Created by kyo__hei on 2016/09/18.
//  Copyright © 2016年 kyo__hei. All rights reserved.
//

import UIKit
import KYShutterButton

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapButton(_ sender: KYShutterButton) {
        switch sender.buttonState {
        case .normal:
            sender.buttonState = .recording
        case .recording:
            sender.buttonState = .normal
        }
    }

}
