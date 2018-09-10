//
//  Model.swift
//  Pentominoes
//
//  Created by John Hannan on 8/28/18.
//  Copyright (c) 2018 John Hannan. All rights reserved.
//

import Foundation

// identifies placement of a single pentomino on a board
struct Position : Codable {
    var x : Int
    var y : Int
    var isFlipped : Bool
    var rotations : Int
}

// A solution is a dictionary mapping piece names ("T", "F", etc) to positions
// All solutions are read in and maintained in an array
typealias Solution = [String:Position]
typealias Solutions = [Solution]

class PentominoModel {
    private let numBoards = 6
    private let numPlayingPieces = 12
    let allSolutions : Solutions //[[String:[String:Int]]]
    private let boards : [String]
    private let boardLetters = ["F", "I", "L", "N", "P",
                                "T", "U", "V", "W", "X", "Y", "Z"]
    private let playingPieces : [String]

    init () {
        let mainBundle = Bundle.main
        let solutionURL = mainBundle.url(forResource: "Solutions", withExtension: "plist")
        
        do {
            let data = try Data(contentsOf: solutionURL!)
            let decoder = PropertyListDecoder()
            allSolutions = try decoder.decode(Solutions.self, from: data)
        } catch {
            print(error)
            allSolutions = []
        }
        var _boards = [String]()
        var _playingPieces = [String]()
        for i in 0..<numBoards {
            _boards.append("Board\(i)")
        }
        for i in 0..<numPlayingPieces {
            _playingPieces.append("Piece\(boardLetters[i])")
        }
        boards = _boards
        playingPieces = _playingPieces
    }
    //Pulled from LionModel
    func boardNames(index i:Int) -> String {
        return boards[i%numBoards]
    }
    
    func playingPiecesNames(index i:Int) -> String {
        return playingPieces[i%numPlayingPieces]
    }
    
    func boardLetterNames(index i:Int) -> String {
        return boardLetters[i%numPlayingPieces]
    }
    
    func playingPiecesNames(character c:String) -> String {
        let index = boardLetters.index(of: c)
        if let i = index{
            return playingPieces[i]
        }else{
            return playingPieces[0]
        }
    }
}
