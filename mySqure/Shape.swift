//
//  Shape.swift
//  mySqure
//
//  Created by Ming Jing on 17/3/21.
//  Copyright © 2017年 Ming Jing. All rights reserved.
//

import SpriteKit

let NumOrientations: UInt32 = 4

// 枚举类型 Orientation
enum Orientation: Int, CustomStringConvertible {
    
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    // Return Random Orientation:
    static func random() -> Orientation {
        return Orientation(rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    // #1 Return the Next Orientation when traveling either clockwise or counterclockwise.
    static func rotate(orientation:Orientation, clockwise: Bool) -> Orientation {
        
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
    }
}

// The number of total shape varieties
let NumShapeTypes: UInt32 = 7

// Shape indexes
let FirstBlockIdx:  Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx:  Int = 2
let FourthBlockIdx: Int = 3


class Shape: Hashable, CustomStringConvertible {
    
    // The color of the shape
    let color:BlockColor
    
    // The blocks comprising the shape
    var blocks = Array<Block>()

    // The current orientation of the shape
    var orientation: Orientation
    
    // The column and row representing the shape's anchor point
    var column, row:Int
    
    // Required Overrides: 定义了两个 computed properties，然后把它们的返回值设置为空，这就好比是C++里面的纯虚函数，必须在它的子类中进行重新定义
    // #2 Dictionary [] -- 字典
    // Subclasses must override this property
    // 总体说来，这个blockRowColumnPositions字典，里面定义的是一个shape的4个方向（这就是为什么key是orientation）时，
    // block的位置（一个shape是由多个block组成的，所以是一个数组；而位置需要坐标来定义，所以需要tuple）。
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    
    // #3 tuple其实就是为了简化开发者的工作量，让我们可以直接定义一个返回multiple variable的结构。
    // Subclasses must override this property
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [:]
    }
    
    // #4  返回处于底部的blocks
    var bottomBlocks:Array<Block> {
    
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
            return []
        }
        
        return bottomBlocks
    }
    
    // Hashable
    var hashValue:Int {
        
        // #5
        return blocks.reduce(0) { $0.hashValue ^ $1.hashValue }
    }
    
    // CustomStringConvertible
    var description:String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    // Init...
    init(column:Int, row:Int, color: BlockColor, orientation:Orientation) {
        self.color  = color
        self.column = column
        self.row    = row
        self.orientation = orientation
        
        initializeBlocks()
    }
    
    // #6 : convenience。 其实就相当于构造函数的重载 ， 之前的那个init在swift里面叫做 designated init，也就是必须要有的，而为什么要叫 convenience 就如它的字面意思一样，是一个便利用户的init，在这里面必须调用之前的 designated init，否则会出错。其实就是在convenience init里面做了一些定制化的操作，例如在我们的程序里面，构造了一个随机颜色，随机方向的shape。
    convenience init(column:Int, row:Int) {
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
    }
    
    // #7  defined a final function which means it cannot be overridden by subclasses.
    final func initializeBlocks() {
        
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
        
        // #8  return a Block object.
        blocks = blockRowColumnTranslations.map { (diff) -> Block in
        
            return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
        }
    }
    
    //
    final func rotateBlocks(orientation: Orientation) {
        
        guard let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else {
       
            return
        }
        
        // #1
        for (idx, diff) in blockRowColumnTranslation.enumerated() {
            blocks[idx].column = column + diff.columnDiff
            blocks[idx].row = row + diff.rowDiff
        }
    }
    
    // #3
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: true)
        rotateBlocks(orientation: newOrientation)
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: false)
        rotateBlocks(orientation: newOrientation)
        orientation = newOrientation
    }
    
    
    // 每次将shape下落一行，而具体如何下落，就看 #2 中的shiftBy函数
    final func lowerShapeByOneRow() {
        shiftBy(columns: 0, rows:1)
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(columns: 0, rows:-1)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(columns: 1, rows:0)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(columns: -1, rows:0)
    }
    
    
    // #2   Move by columns and rows
    final func shiftBy(columns: Int, rows: Int) {
        
        self.column += columns
        self.row += rows
        
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    // #3 直接将blocks移动到指定的行和列
    final func moveTo(column: Int, row:Int) {
        
        self.column = column
        self.row = row
        
        rotateBlocks(orientation: orientation)
    }
    
    final class func random(startingColumn:Int, startingRow:Int) -> Shape {
        
        switch Int(arc4random_uniform(NumShapeTypes)) {
        // #4
        case 0:
            return SquareShape(column:startingColumn, row:startingRow)
        case 1:
            return LineShape(column:startingColumn, row:startingRow)
        case 2:
            return TShape(column:startingColumn, row:startingRow)
        case 3:
            return LShape(column:startingColumn, row:startingRow)
        case 4:
            return JShape(column:startingColumn, row:startingRow)
        case 5:
            return SShape(column:startingColumn, row:startingRow)
        default:
            return ZShape(column:startingColumn, row:startingRow)
        }
    }
}


func ==(lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}
