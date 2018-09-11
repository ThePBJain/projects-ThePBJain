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
    @IBOutlet weak var invisibleView: UIView!
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var mainBoard: UIImageView!
    @IBOutlet var boardButtons: [UIButton]!
    let pentominoModel = PentominoModel()
    let pieces : [String:UIImageView]
    let pieceDimension: Int
    let pieceBlockPixel: Int
    var currentGame = 0
    let animationTime = 1.0
    let standardRotation = CGFloat.pi/2.0
    
    required init?(coder aDecoder: NSCoder) {
        var _pieces = [String:UIImageView]()
        for i in 0..<pentominoModel.getNumPlayingPieces(){
            let _key = pentominoModel.boardLetterNames(index: i)
            let _pieceView = UIImageView(image: UIImage(named: pentominoModel.playingPiecesNames(index: i)))
            _pieceView.contentMode = UIViewContentMode.scaleAspectFit
            _pieceView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, .flexibleHeight]
            _pieces[_key] = _pieceView
        }
        pieces = _pieces
        pieceDimension = pentominoModel.getPieceDimension()
        pieceBlockPixel = pentominoModel.getPieceBlockPixel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //write pieceviews down
        resetBoard(UIButton())
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutPieces(){
        let numPiecesPerRow: Int = Int(self.bottomView.frame.size.width)/(pieceDimension*pieceBlockPixel)
        var counterX = 0
        var counterY = 0
        for aView in pieces.values {
            //calculate positions in view
            let _x = counterX%numPiecesPerRow * (pieceDimension*pieceBlockPixel)
            counterY = counterX / numPiecesPerRow
            let _y = counterY * ((pieceDimension)*pieceBlockPixel)
            counterX += 1
            aView.frame.origin = CGPoint(x: _x, y: _y)
        }
    }
    
    //gotten from Move Views that Dr. Hannan made
    func moveView(_ view:UIView, toSuperview superView: UIView) {
        let newCenter = superView.convert(view.center, from: view.superview)
        view.center = newCenter
        superView.addSubview(view)
    }

    @IBAction func setPlayingBoard(_ sender: UIButton) {
        self.currentGame = sender.tag
        mainBoard.image = UIImage(named: pentominoModel.boardNames(index: sender.tag))
    }
    
    @IBAction func solveBoard(_ sender: Any) {
        if(currentGame != 0){
            let currentSolution = pentominoModel.allSolutions[self.currentGame-1]
            for (key, value) in currentSolution{
                let _x = value.x * pieceBlockPixel
                let _y = value.y * pieceBlockPixel
                let _rotate = CGFloat(value.rotations) * standardRotation;
                let _isFlipped = value.isFlipped
                if let pieceView = pieces[key]{
                    moveView(pieceView, toSuperview: mainBoard)
                    UIView.animate(withDuration: animationTime, animations: { () -> Void in
                        //create a transform matrix to apply to pieceView
                        var stackedTransform = CGAffineTransform.identity
                        stackedTransform = stackedTransform.rotated(by: _rotate)
                        if(_isFlipped){
                            //invert on y-axis (i.e reverse x)
                            stackedTransform = stackedTransform.scaledBy(x: -1, y: 1)
                        }
                        pieceView.transform = stackedTransform
                        pieceView.frame.origin = CGPoint(x: _x, y: _y)
                    })
                }
            }
            
            //disable/enable buttons
            for button in boardButtons{
                button.isEnabled = false
            }
            solveButton.isEnabled = false
            resetButton.isEnabled = true
        }
    }
    
    @IBAction func resetBoard(_ sender: Any) {
        
        for piece in pieces.values{
            moveView(piece, toSuperview: self.invisibleView)
            UIView.animate(withDuration: animationTime, animations: { () -> Void in
                //reset transforms
                piece.transform = CGAffineTransform.identity
                //reset location
                self.layoutPieces()
            })
        }
        //disable/enable buttons
        for button in boardButtons{
            button.isEnabled = true
        }
        solveButton.isEnabled = true
        resetButton.isEnabled = false
    }

}

