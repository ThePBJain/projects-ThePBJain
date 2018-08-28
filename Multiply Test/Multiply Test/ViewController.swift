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
    let maxMultiple:UInt32 = 15
    let minMultiple:UInt32 = 1
    let numSegments:UInt32 = 4
    let answerRange:UInt32 = 10
    let numQuestions = 5
    var answerIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func loadQuestion() {
        answerChoices.selectedSegmentIndex = -1
        
        let multiplicandValue = arc4random_uniform(maxMultiple) + minMultiple
        let multiplierValue = arc4random_uniform(maxMultiple) + minMultiple
        
        multiplicand.text = String(multiplicandValue)
        multiplier.text = String(multiplierValue)
        
        let answer = multiplicandValue * multiplierValue
        result.text = String(answer)
        answerIndex = Int(arc4random_uniform(numSegments))
        
        //load correct answer and other answerChoices
        if let index = answerIndex {
            for i in 0...numSegments-1 {
                if(i == index){
                    answerChoices.setTitle(String(answer), forSegmentAt: index)
                }else{
                    let wrongAnswer = 1//arc4random_uniform(answerRange + 1) - (answerRange/2) + answer
                    answerChoices.setTitle(String(wrongAnswer), forSegmentAt: Int(i))
                }
            }
        }else{
            //answer will be in first index if answerIndex fails to contain anything
        }
        answerChoices.isEnabled = true
        
    }
    @IBAction func nextQuestion(_ sender: Any) {
        correctnessIndicator.isHidden = true
        answerChoices.isEnabled = false
        result.isHidden = true
        loadQuestion()
    }
    @IBAction func answerChosen(_ sender: Any) {
        result.isHidden = false
        if let correctIndex = answerIndex {
            if(answerChoices.selectedSegmentIndex == correctIndex){
                correctnessIndicator.text = "Correct!"
                correctnessIndicator.isHidden = false
            }else{
                correctnessIndicator.text = "Wrong"
                correctnessIndicator.isHidden = false
            }
        }else{
            //answer will be in first index if answerIndex fails to contain anything
            if(answerChoices.selectedSegmentIndex == 0){
                correctnessIndicator.text = "Correct!"
                correctnessIndicator.isHidden = false
            }else{
                correctnessIndicator.text = "Wrong"
                correctnessIndicator.isHidden = false
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

