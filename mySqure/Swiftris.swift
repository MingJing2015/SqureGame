//
//  Swiftris.swift
//  mySqure
//
//  Created by Ming Jing on 17/3/21.
//  Copyright © 2017年 Ming Jing. All rights reserved.
//
//  a class that manages Swiftris' game logic

let NumColumns = 10
let NumRows    = 20

let StartingColumn = 4
let StartingRow    = 0

// Right Side
let PreviewColumn = 12
let PreviewRow    = 1

// For scoring
let PointsPerLine = 10
let LevelThreshold = 500

// 自己的protocol
protocol SwiftrisDelegate {
    
    // Invoked when the current round of Swiftris ends
    func gameDidEnd(swiftris: Swiftris)
    
    // Invoked after a new game has begun
    func gameDidBegin(swiftris: Swiftris)
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(swiftris: Swiftris)
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(swiftris: Swiftris)
}


class Swiftris {
    
    
    // settleShape函数会在shape无法再往下落的时候调用，我们把当前shape中的所有block都写入到blockArray里面，然后告诉程序，
    // 这个shape已经成功着陆了，不管它是真的着陆还是降落在别的shape头上; ** From Falling Shape into blockArray ***
    var blockArray:Array2D<Block>
    
    // 预览下一个是什么形状
    var nextShape:Shape?
    
    // 正在操作的shape，可以旋转，移动等等来操作它
    var fallingShape:Shape?

    
    var delegate:SwiftrisDelegate?
    
    var score = 0
    var level = 1
    
    init() {
        fallingShape = nil
        nextShape    = nil
        blockArray   = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    // 随机生成一个shape，用shape类中最后写的那个函数，然后把它放在我们制定的位置中
    func beginGame() {
        
        // First, Random build the first Shape as nextShape...
        if (nextShape == nil) {
            
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        }
        
         delegate?.gameDidBegin(swiftris: self)
    }
    
    // #6 movtTo函数把他一到我们的游戏区域的中间，然后生成一个新的nextshape
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
        
        // next change to falling
        fallingShape = nextShape
        
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        
        // Put to Start Position, prepare to fall... 
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        
        // #1 detect the ending of a Switris game. 
        // The game ends when a new shape located at the designated starting location collides with existing blocks. 
        // This is the case where the player no longer has room to move the new shape, and we must destroy their tower of terror.
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        
        
        return (fallingShape, nextShape)
    }
    
    // #2 checking both block boundary conditions
    // whether a block exceeds the legal size of the game board. 
    // The second determines whether a block's current location overlaps with an existing block.
    // 试错法（trial-and-error）
    func detectIllegalPlacement() -> Bool {
        
        guard let shape = fallingShape else {
            return false
        }
        
        for block in shape.blocks {
        
            if block.column < 0 || block.column >= NumColumns
                || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    // #4  Dropping a shape is the act of sending it plummeting towards the bottom of the game board.
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        
        // detects an illegal placement state, at which point it will raise it and then notify the delegate that a drop has occurred.
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        // 复原到最后一个合法的位置
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidDrop(swiftris: self)
    }
    
    // #5  call once every tick. This attempts to lower the shape by one row and ends the game if it fails to do so without finding legal placement for it.
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        shape.lowerShapeByOneRow()
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            delegate?.gameShapeDidMove(swiftris: self)
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    // #6  rotate the shape clockwise as it falls 
    // If its new block positions violate the boundaries of the game or overlap with settled blocks, we revert the rotation and return. 
    // Otherwise, we let the delegate know that the shape has moved.
    func rotateShape() {
        
        guard let shape = fallingShape else {
            return
        }
        
        // ??
        //shape.rotateClockwise()
        // Ok ??
        shape.rotateCounterClockwise()
        
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        
        delegate?.gameShapeDidMove(swiftris: self)
    }
    
    // #7 leftwards or rightwards.
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftLeftByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(swiftris: self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(swiftris: self)
    }
    
    // #8  Once the falling shape's blocks are part of the game board, we nullify fallingShape and notify the delegate of 
    // a new shape settling onto the game board.
    // settleShape函数会在shape无法再往下落的时候调用，我们把当前shape中的所有block都写入到blockArray里面，然后告诉程序，这个shape已经成功着陆了，不管它是真的着陆还是降落在别的shape头上，#2中的函数正是完成这样的检测；
    // 同时fallingshape设置成nil，这样swiftris就会开始新的fallingshape
    
    func settleShape() {
        
        guard let shape = fallingShape else {
            return
        }
        
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        
        fallingShape = nil
        delegate?.gameShapeDidLand(swiftris: self)
    }
    
    // #9  Detect: when a shape should settle
    // one of the shapes' bottom blocks touches a block on the game board 
    // or,  when one of those same blocks has reached the bottom of the game board
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1
                || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        
        score = 0
        level = 1
        
        delegate?.gameDidEnd(swiftris: self)
    }
    
    
    // #10  linesRemoved maintains each row of blocks which the user has filled in
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        for row in (1..<NumRows).reversed() {
            var rowOfBlocks = Array<Block>()
            
            // #11  from 0 all the way up to, but not including NumColumns, 0 to 9
            // adds every block in a given row to a local array variable named rowOfBlocks. 
            // If it ends up with a full set, 10 blocks in total, it counts that as a removed line and adds it to the return variable.
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // #12
        if removedLines.count == 0 {
            return ([], [])
        }
        
        // #13  we add points to the player's score based on the number of lines they've created and their level. 
        // If their points exceed their level times 1000, they level up and we inform the delegate.
        
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(swiftris: self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            
            // #14  Starting in the left-most column and above the bottom-most removed line, we count upwards towards the top of the game board. As we do so, we take each remaining block we find on the game board and lower it as far as possible. fallenBlocks is an array of arrays, we've filled each sub-array with blocks that fell to a new position as a result of the user clearing lines beneath them.
            for row in (1..<removedLines[0][0].row).reversed() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                var newRow = row
                while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    // This function loops through and creates rows of blocks in order for the game scene to animate them off the game board. Meanwhile, 
    // it nullifies each location in the block array to empty it entirely, 
    // preparing it for a new game.  *** Clear Them !
    // ????
    func removeAllBlocks() -> Array<Array<Block>> {
    
        var allBlocks = Array<Array<Block>>()
        
        for row in 0..<NumRows {
        
            var rowOfBlocks = Array<Block>()
            
            for column in 0..<NumColumns {
                
                guard let block = blockArray[column, row] else {
                    continue
                }
                
                rowOfBlocks.append(block)
                blockArray[column, row] = nil
            }
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
}
