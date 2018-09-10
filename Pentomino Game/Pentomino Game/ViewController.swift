//
//  ViewController.swift
//  Pentomino Game
//
//  Created by Pranav Jain on 9/6/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var mainBoard: UIImageView!
    @IBOutlet var boardButtons: [UIButton]!
    let pentominoModel = PentominoModel()
    let pieces : [String:UIImageView]
    let pieceDimension = 4
    let pieceBlockPixel = 30
    var currentGame = 0
    required init?(coder aDecoder: NSCoder) {
        var _pieces = [String:UIImageView]()
        for i in 0..<12{
            //let img = UIImage(named: pentominoModel.playingPiecesNames(index: i))
            //print("SIZE IS: \(String(describing: img?.size.width))")
            let _pieceView = UIImageView(image: UIImage(named: pentominoModel.playingPiecesNames(index: i)))
            _pieceView.contentMode = UIViewContentMode.scaleAspectFit
            _pieceView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, .flexibleHeight]
            let _key = pentominoModel.boardLetterNames(index: i)
            _pieces[_key] = _pieceView
        }
        pieces = _pieces
        
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        layoutPieces()
    }
    
    func layoutPieces(){
        let numPiecesPerRow: Int = Int(self.bottomView.frame.size.width)/(pieceDimension*pieceBlockPixel)
        //let numRows: Int = Int(self.bottomView.frame.size.height)/(pieceDimension*pieceBlockPixel)
        var counterX = 0
        var counterY = 0
        for aView in pieces.values {
            let _x = counterX%numPiecesPerRow * (pieceDimension*pieceBlockPixel)
            counterY = counterX / numPiecesPerRow
            let _y = counterY * ((pieceDimension+2)*pieceBlockPixel)
            counterX += 1
            aView.frame.origin = CGPoint(x: _x, y: _y)
            self.bottomView.addSubview(aView)
        }
    }
    func resetTransforms(){
        if(currentGame != 0){
            let currentSolution = pentominoModel.allSolutions[self.currentGame-1]
            for (key, value) in currentSolution{
                let _rotate = -1.0*CGFloat(value.rotations) * (CGFloat.pi/2.0);
                let _isFlipped = value.isFlipped
                if let pieceView = pieces[key]{
                    if(_isFlipped){
                        if let pieceImage = pieceView.image{
                            pieceView.image = pieceImage.withHorizontallyFlippedOrientation()
                        }
                    }
                    pieceView.transform = pieceView.transform.rotated(by: _rotate)
                    
                }
            }
        }
    }
    
    
    

    @IBAction func setPlayingBoard(_ sender: Any) {
        let button = sender as! UIButton
        self.currentGame = button.tag
        mainBoard.image = UIImage(named: pentominoModel.boardNames(index: button.tag))
    }
    @IBAction func solveBoard(_ sender: Any) {
        if(currentGame != 0){
            let currentSolution = pentominoModel.allSolutions[self.currentGame-1]
            for (key, value) in currentSolution{
                let _x = value.x * pieceBlockPixel
                let _y = value.y * pieceBlockPixel
                let _rotate = 1.0*CGFloat(value.rotations) * (CGFloat.pi/2.0);
                let _isFlipped = value.isFlipped
                if let pieceView = pieces[key]{
                    pieceView.transform = pieceView.transform.rotated(by: _rotate)
                    if(_isFlipped){
                        if let pieceImage = pieceView.image{
                            pieceView.image = pieceImage.withHorizontallyFlippedOrientation()
                        }
                    }
                    pieceView.frame.origin = CGPoint(x: _x, y: _y)
                    self.mainBoard.addSubview(pieceView)
                }
            }
            solveButton.isEnabled = false
            resetButton.isEnabled = true
        }
    }
    @IBAction func resetBoard(_ sender: Any) {
        resetTransforms()
        layoutPieces()
        solveButton.isEnabled = true
        resetButton.isEnabled = false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //write views down
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

