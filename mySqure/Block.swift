//
//  Block.swift
//  mySqure
//
//  Created by Ming Jing on 17/3/21.
//  Copyright © 2017年 Ming Jing. All rights reserved.
//

import SpriteKit

// #1
let NumberOfColors: UInt32 = 6

// #2  enumeration， 枚举类型; 遵循一个协议  printable
enum BlockColor: Int, CustomStringConvertible {

    // #3
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    // #4 -- define a computed property: 可供计算的性质
    var spriteName: String {
        
        switch self {
            
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    // #5 -- computed property, description, because : CustomStringConvertible
    var description: String {
        return self.spriteName
    }

    // #6 static 函数
    static func random() -> BlockColor {
        
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}

// #7  Define Class
// implements both the CustomStringConvertible and Hashable protocols. Hashable allows us to store Block in Array2D.
// 会同时执行协议Printable和Hashable， 其中hashable将允许我们的Block存储在Array2D中
class Block: Hashable, CustomStringConvertible {
        
    // #8
    // Constants
    let color: BlockColor
        
    // #9
    // Properties
 
    var column: Int
    var row   : Int
    
    // SKSpriteNode ??? Where the Type ?? will represent the visual element of the Block which GameScene will use to render and animate each Block.
    // SKSpriteNode将会在GameScene对每一个block着色和动画的时候将其描绘在屏幕上
    var sprite: SKSpriteNode?
        
    // #10  he sprite's file name - 调用的是block.color.spriteName
    var spriteName: String {
            return color.spriteName
    }
        
    // #11 generate a unique integer for each Block.
    var hashValue: Int {
            return self.column ^ self.row
    }
 
    // #12  For prints, display : blue: [8, 3]
    var description: String {
            return "\(color): [\(column), \(row)]"
    }
        
    init(column:Int, row:Int, color:BlockColor) {
        
        self.column = column
        self.row = row
        self.color = color
    }
}
    
// #13  custom operator, ==, when comparing one Block with another. It returns true if both Blocks are in the same location and of the same color

func ==(lhs: Block, rhs: Block) -> Bool {

    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue

}
