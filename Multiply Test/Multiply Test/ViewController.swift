//
//  ViewController.swift
//  Multiply Test
//
//  Created by Pranav Jain on 8/26/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var multiplicand: UILabel!
    @IBOutlet weak var multiplier: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var answerChoices: UISegmentedControl!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var correctnessIndicator: UILabel!
    let maxMultiple:UInt32 = 15
    let minMultiple:UInt32 = 1
    let numSegments:UInt32 = 4
    let answerRange:UInt32 = 10
    let numQuestions = 5
    var answerIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        resetTest()
    }
    func resetTest() {
        correctnessIndicator.isHidden = true
        progress.isHidden = true
        answerChoices.isEnabled = false
        result.isHidden = true
        progressBar.setProgress(0.0, animated: true)
        mainButton.isHidden = false
        mainButton.setTitle("Start", for: UIControlState.normal)
    }
    func loadAnswerChoices(answerIndex index: Int, answer: UInt32) {
        for i in 0...numSegments-1 {
            var usedAnswers = [Int(answer)]
            if(i == index){
                answerChoices.setTitle(String(answer), forSegmentAt: index)
            }else{
                //cast as Int to protect against negative numbers
                var wrongAnswer = Int(arc4random_uniform(answerRange)) + Int(answer) - Int(answerRange/2)
                while(usedAnswers.contains(wrongAnswer) || wrongAnswer < 1) {
                    wrongAnswer = Int(arc4random_uniform(answerRange) + answer - (answerRange/2))
                }
                usedAnswers.append(wrongAnswer)
                answerChoices.setTitle(String(wrongAnswer), forSegmentAt: Int(i))
            }
        }
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
            loadAnswerChoices(answerIndex: index, answer: answer)
        }else{
            //answer will be in first index if answerIndex fails to contain anything
            loadAnswerChoices(answerIndex: 0, answer: answer)
        }
        answerChoices.isEnabled = true
        
    }
    @IBAction func nextQuestion(_ sender: Any) {
        if(mainButton.titleLabel?.text == "Reset"){
            resetTest()
        }else{
            progress.isHidden = false
            correctnessIndicator.isHidden = true
            answerChoices.isEnabled = false
            result.isHidden = true
            mainButton.isHidden = true
            progressBar.setProgress(progressBar.progress + (1.0/Float(numQuestions)), animated: true)
            if(progressBar.progress == 1.0){
                mainButton.setTitle("Reset", for: UIControlState.normal)
            }else{
                mainButton.setTitle("Next", for: UIControlState.normal)
            }
            loadQuestion()
        }
    }
    @IBAction func answerChosen(_ sender: Any) {
        result.isHidden = false
        mainButton.isHidden = false
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

