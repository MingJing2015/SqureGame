//
//  SquareShape.swift
//  mySqure
//
//  Created by Ming Jing on 17/3/21.
//  Copyright © 2017年 Ming Jing. All rights reserved.
//

class SquareShape:Shape {
    
    /*
    
     // #9
     | 0•| 1 |
     | 2 | 3 |
     
     • marks the row/column indicator for the shape
     */
    
    // The square shape will not rotate
    
    // #10
    override var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero:       [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.OneEighty:  [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.Ninety:     [(0, 0), (1, 0), (0, 1), (1, 1)],
            Orientation.TwoSeventy: [(0, 0), (1, 0), (0, 1), (1, 1)]
        ]
    }
    
    // #11  a square shape does not rotate, so its bottom-most blocks are consistently the third and fourth blocks as indicated by the comments at #9.
    override var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [
            Orientation.Zero:       [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty:  [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety:     [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}
