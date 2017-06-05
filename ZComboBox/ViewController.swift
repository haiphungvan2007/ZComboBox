//
//  ViewController.swift
//  ZComboBox
//
//  Created by haipv on 4/18/17.
//  Copyright © 2017 haipv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var abc: ZComboBox!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        abc.items = ["abc", "xyz", "xyz", "xyz", "xyz", "xyz", "xyz", "xyz", "xyz", "xyz", "xyz", "xyz", "xyz", "xyz"]
        self.abc.layer.cornerRadius = 5.0;
        self.abc.layer.borderColor = UIColor.gray.cgColor
        self.abc.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

