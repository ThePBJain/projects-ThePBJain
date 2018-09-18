//
//  HintViewController.swift
//  Pentomino Game
//
//  Created by Pranav Jain on 9/18/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class HintViewController: UIViewController {

    @IBOutlet weak var mainBoard: UIImageView!
    let pentominoModel = PentominoModel()
    let pieces : [String:UIImageView]
    let standardRotation = CGFloat.pi/2.0
    let pieceBlockPixel: Int
    var completionBlock : (() -> Void)?
    var currentHint = 0;
    var currentGame = 0;
    
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
        pieceBlockPixel = pentominoModel.getPieceBlockPixel()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainBoard.image = UIImage(named: pentominoModel.boardNames(index: self.currentGame))
        // Do any additional setup after loading the view.
        let currentSolution = pentominoModel.allSolutions[self.currentGame-1]
        var i = 0;
        for (key, value) in currentSolution{
            if(i >= currentHint){
                break;
            }
            let _x = value.x * pieceBlockPixel
            let _y = value.y * pieceBlockPixel
            let _rotate = CGFloat(value.rotations) * standardRotation;
            let _isFlipped = value.isFlipped
            if let pieceView = pieces[key]{
                
                //create a transform matrix to apply to pieceView
                var stackedTransform = CGAffineTransform.identity
                stackedTransform = stackedTransform.rotated(by: _rotate)
                if(_isFlipped){
                    //invert on y-axis (i.e reverse x)
                    stackedTransform = stackedTransform.scaledBy(x: -1, y: 1)
                }
                pieceView.transform = stackedTransform
                pieceView.frame.origin = CGPoint(x: _x, y: _y)
                self.mainBoard.addSubview(pieceView)
            }
            i+=1;
        }
    }
    
    func configure(with currentGame:Int, currentHint:Int) {
        self.currentGame = currentGame
        self.currentHint = currentHint
        print(currentHint)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishedWithHint(_ sender: Any) {
        if let completionBlock = completionBlock {
            completionBlock()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
