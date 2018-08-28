//
//  ViewController.swift
//  Multiply Test
//
//  Created by Pranav Jain on 8/26/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var multiplicand: UILabel!
    @IBOutlet weak var multiplier: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var answerChoices: UISegmentedControl!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var correctnessIndicator: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func nextQuestion(_ sender: Any) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

