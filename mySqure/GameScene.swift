//
//  GameScene.swift
//  mySqure
//
//  Created by Ming Jing on 17/3/21.
//  Copyright © 2017年 Ming Jing. All rights reserved.
//

import SpriteKit

// #7  define the point size of each block sprite, in our case 20.0 x 20.0, the lower of the available resolution options for each block image. We also declare a layer position which will give us an offset from the edge of the screen.

let BlockSize: CGFloat = 20.0

// #1
// represent the slowest speed at which our shapes will travel. 
// every 6/10ths of a second, our shape should descend by one row.  600 milliseconds
//let TickLengthLevelOne = TimeInterval(600)
let TickLengthLevelOne = TimeInterval(2000)

class GameScene: SKScene {
    
    // #8  SKNodes??? which act as superimposed Layers of activity within our scene.
    //     The gameLayer sits above the background visuals and the shapeLayer sits atop that.
    // 最下面的是gameLayer，它上一层是shapeLayer，然后是gameBoard
    
    
    let gameLayer = SKNode()
    
    let shapeLayer = SKNode()
    
    // ?? let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat(NumColumns), BlockSize * CGFloat(NumRows)))

    
    // ???
    let LayerPosition = CGPoint(x: 6, y: -6)
    
    // #2  闭包
    // a block of code that performs a function
    // Closures are self-contained blocks of functionality that can be passed around and used in your code.
    var tick:(() -> ())?
    
    // the GameScene's current tick length, set to TickLengthLevelOne by default
    var tickLengthMillis = TickLengthLevelOne
    
    // rack the last time we experienced a tick, an NSDate object.  ??
    // But if lastTick is present, we recover the time passed since the last execution of update by invoking timeIntervalSinceNow on our lastTick object. We multiply the result by -1000 to calculate a positive millisecond value. We invoke functions on objects using dot syntax in Swift.
    
    //var lastTick:NSDate 最后一次记录的时间
    var lastTick: Date?
    
    var textureCache = Dictionary<String, SKTexture>()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }

    override init(size: CGSize) {
        super.init(size: size)
        
        // create an SKSpriteNode capable of representing our background image and we add it to the scene.
        let background = SKSpriteNode(imageNamed: "background")
        
        var dx = 0.0
        if( size.width > background.size.width ){
            dx = (Double((size.width - background.size.width) / size.width) )
            dx /= 2
        }
        
        var dy = 1.0
        if( size.height > background.size.height ) {
            dy = (Double((size.height - background.size.height) / size.height) )
            dy /= 2
            dy = 1 - dy
        }

        // anchor our game in the top-left corner of the screen: (0, 1.0).
        anchorPoint = CGPoint(x: 0, y: 1.0)
        //anchorPoint = CGPoint(x: dx, y: dy)
        
        // ???
        background.position     = CGPoint(x: 0, y: 0)
        
        // Always stay at left top corner
        background.anchorPoint  = CGPoint(x: 0, y: 1.0)
        
        // Do not Move background.anchorPoint
        
        //background.anchorPoint  = CGPoint(x: dx, y: dy)
        
        addChild(background)
        
        // ??
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        //let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSizeMake(BlockSize * CGFloat
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width:BlockSize * CGFloat(NumColumns), height:BlockSize * CGFloat(NumRows)))
       
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position   = LayerPosition
        
        
//        print("init width: \(size.width)")
//        print("init height: \(size.height)")
//        
//        print("background width: \(background.size.width)")
//        print("background height: \(background.size.height)")
//        
//        print("gameBoard width: \(gameBoard.size.width)")
//        print("gameBoard height: \(gameBoard.size.height)")
//
//        print("dx: \(dx)")
//        print("dy: \(dy)")

        
        // ???
        shapeLayer.position   = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        // Sound
        run(SKAction.repeatForever(SKAction.playSoundFileNamed("Sounds/theme.mp3", waitForCompletion: true)))
    }

    func playSound(sound:String) {
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Called before each frame is rendered
        
        // #3
        // Swift's guard statement checks the conditions which follow it, let lastTick = lastTick in our case. 
        // If the conditions fail, guard executes the else block.
        // If lastTick is missing, the game is in a paused state and not reporting elapsed ticks, so we return.
        
        guard let lastTick = lastTick else {
            
            // Pause, then return
            return
        }
        
        // calculate has passed time
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        
        // Get Enough time, then action 1 time
        if timePassed > tickLengthMillis {
        
            //self.lastTick = NSDate()
            self.lastTick = Date()
            
            tick?()
        }
    }
    
    // #4
    // accessor methods to let external classes stop and start the ticking process,
    
    func startTicking() {
        
        //lastTick = NSDate()
        lastTick = Date()
    }
    
    func stopTicking() {
        
        lastTick = nil
    }
    
    // #9 根据column和row来计算每一个block的锚点位置，所以返回的是一个point坐标，只有根据这个坐标，我们才能把每个block放置在shapeLayer上。
    // 其实它计算的就是每个block的中心点的坐标
    func pointForColumn(column: Int, row: Int) -> CGPoint {

        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        
        //return CGPointMake(x, y)
        return CGPoint(x: x, y: y)
    }
    
    // Prepare the first One , at right position ***  -- 把新生成的nextShape添加到屏幕中去
    // 函数其中的一个参数用的是一个空的闭包，因为函数最后有个添加动作的函数runAction，它里面有个参数 completion，这里我们用个()->() 闭包还是个占位的
    func addPreviewShapeToScene(shape:Shape, completion:@escaping () -> ()) {

        for block in shape.blocks {
        
            // #10 : 把SKTexture对象存在一个字典里面，因为每一个shape会有很多block，而我们是要重复利用这些image
            var texture = textureCache[block.spriteName]
            
            if texture == nil {
                
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            
            let sprite = SKSpriteNode(texture: texture)
            
            // #11: 用到了之前定义的pointForColumn函数精确地每一个block添加到准确的位置，我们是从row-2开始的，这样可以显得我们的动画更加平滑地进入画面中
            sprite.position = pointForColumn(column: block.column, row:block.row - 2)
            
            shapeLayer.addChild(sprite)
            
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            
            // #12  :  添加了一组动画，我们让每个block的alpha从0变化到0.7 ，因为这样更容易让用户有一种动画的感觉
            let moveAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: TimeInterval(0.2))
            moveAction.timingMode = .easeOut
            
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        
        //runAction(SKAction.waitForDuration(0.4), completion: completion)
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    // From prepare position to falling position action **
    func movePreviewShape(shape:Shape, completion:@escaping () -> ()) {
        
        for block in shape.blocks {
        
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
        }

        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    // Redraw Falling action
    func redrawShape(shape:Shape, completion:@escaping () -> ()) {
        
        for block in shape.blocks {
        
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            
            moveToAction.timingMode = .easeOut
            
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
    // Blow It Up ...
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:@escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        // #2
        for (columnIdx, column) in fallenBlocks.enumerated() {
            for (blockIdx, block) in column.enumerated() {
                let newPosition = pointForColumn(column: block.column, row: block.row)
                let sprite = block.sprite!
                // #3
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                // #4
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                var point = pointForColumn(column: block.column, row: block.row)
                point = CGPoint(x: point.x + (goLeft ? -randomRadius : randomRadius), y: point.y)
                
                
                let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
                // #5
                var startAngle = CGFloat(M_PI)
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                let archAction = SKAction.follow(archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
                archAction.timingMode = .easeIn
                let sprite = block.sprite!
                // #6
                sprite.zPosition = 100
                sprite.run(
                    SKAction.sequence(
                        [SKAction.group([archAction, SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]),
                         SKAction.removeFromParent()]))
            }
        }
        // #7
        run(SKAction.wait(forDuration: longestDuration), completion:completion)
    }
}
