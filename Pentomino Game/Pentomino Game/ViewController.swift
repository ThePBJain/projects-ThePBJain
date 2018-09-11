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
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //write piece views down
        resetBoard(UIButton())
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func setPlayingBoard(_ sender: Any) {
        let button = sender as! UIButton
        self.currentGame = button.tag
        mainBoard.image = UIImage(named: pentominoModel.boardNames(index: button.tag))
    }
    
    //gotten from Move Views that Dr. Hannan made
    func moveView(_ view:UIView, toSuperview superView: UIView) {
        let newCenter = superView.convert(view.center, from: view.superview)
        view.center = newCenter
        superView.addSubview(view)
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
                    moveView(pieceView, toSuperview: mainBoard)
                    UIView.animate(withDuration: 1.0, animations: { () -> Void in
                        
                        var stackedTransform = CGAffineTransform.identity
                        stackedTransform = stackedTransform.rotated(by: _rotate)
                        if(_isFlipped){
                            stackedTransform = stackedTransform.scaledBy(x: -1, y: 1)
                        }
                        pieceView.transform = stackedTransform
                        pieceView.frame.origin = CGPoint(x: _x, y: _y)
                    })
                }
            }
            for button in boardButtons{
                button.isEnabled = false
            }
            solveButton.isEnabled = false
            resetButton.isEnabled = true
        }
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
        }
    }
    
    @IBAction func resetBoard(_ sender: Any) {
        
        for piece in pieces.values{
            moveView(piece, toSuperview: self.invisibleView)
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                //reset transforms
                piece.transform = CGAffineTransform.identity
                //reset location
                self.layoutPieces()
            })
        }
        
        
        
        for button in boardButtons{
            button.isEnabled = true
        }
        solveButton.isEnabled = true
        resetButton.isEnabled = false
    }


}

