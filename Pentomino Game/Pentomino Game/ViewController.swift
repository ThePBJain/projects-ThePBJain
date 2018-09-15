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
    let shadowSize : CGFloat = 5.0
    //MARK: - View Controller Methods
    
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
        for piece in pieces.values{
            //TODO: get the tap recognizers only work in mainBoard
            let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.rotatePiece(_:)))
            piece.addGestureRecognizer(singleTapRecognizer)
            
            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.flipPiece(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            singleTapRecognizer.require(toFail: doubleTapRecognizer)
            piece.addGestureRecognizer(doubleTapRecognizer)
            
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.movePiece(_:)))
            piece.addGestureRecognizer(panRecognizer)
            
            //OMG SERIOUSLY DONT FORGET THIS! ITS WHAT ALLOWS THE GESTURES TO BE RECOGNIZED IN THE FIRST PLACE
            piece.isUserInteractionEnabled = true
            
        }
        
        //Reset does not belong here, needs to happen after views have been laid out, but did layout subviews gets called too much causing boards to be reset unessessarily find a singleton
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //found it!
        resetBoard(UIButton())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //write pieceviews down
        //resetting unnessessarily because of new subviews being laid out when moving
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Custom Methods
    
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
    
    //gotten from Squares sample code Dr. Hannan made
    func dropShadow(To view:UIView, Add isAdding:Bool) {
        if isAdding {
            view.layer.masksToBounds = false
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.7
            view.layer.shadowOffset = CGSize(width: shadowSize, height: shadowSize)
            view.layer.shadowRadius = shadowSize
        }else{
            view.layer.shadowOpacity = 0.0
            view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            view.layer.shadowRadius = 0.0
        }
    }
    
    //MARK: - Gesture Recognizer Actions
    
    @objc func rotatePiece(_ sender: UITapGestureRecognizer) {
        print("inRotate")
        let pieceView = sender.view as? UIImageView
        if let piece = pieceView {
            var stackedTransform = piece.transform
            stackedTransform = stackedTransform.rotated(by: standardRotation)
            piece.transform = stackedTransform
        }
        //otherwise do nothing
    }
    
    @objc func flipPiece(_ sender: UITapGestureRecognizer) {
        print("inFlip")
        let pieceView = sender.view as? UIImageView
        if let piece = pieceView {
            var stackedTransform = piece.transform
            stackedTransform = stackedTransform.scaledBy(x: -1, y: 1)
            piece.transform = stackedTransform
        }
    }
    
    @objc func movePiece(_ sender: UIPanGestureRecognizer) {
        print("inMove")
        let pieceView = sender.view!
        
        switch sender.state {
        case .began:
            //moveView(pieceView, toSuperview: self.view)
            self.view.bringSubview(toFront: pieceView)
            var pieceTransform = pieceView.transform
            pieceTransform = pieceTransform.scaledBy(x: 1.1, y: 1.1)
            pieceView.transform = pieceTransform
            dropShadow(To: pieceView, Add: true)
            //moveView(pieceView, toSuperview: self.view)
        case .changed:
            let location = sender.location(in: pieceView.superview)
            pieceView.center = location
        case .ended:
            moveView(pieceView, toSuperview: self.view)
            // Should not reset everything.
            pieceView.transform = pieceView.transform.scaledBy(x: 10.0/11.0, y: 10.0/11.0)
            dropShadow(To: pieceView, Add: false)
            if self.mainBoard.frame.contains(pieceView.frame) {
                //move to mainBoard
                print("IN HERE-------")
                //fix this to allow you to move it back out of mainboard...or maybe its fine
                moveView(pieceView, toSuperview: self.mainBoard)
                //TODO: have piece snap into place
            }
        default:
            break
        }
    }
    
    
    //MARK: - Action Methods

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
    }

}

