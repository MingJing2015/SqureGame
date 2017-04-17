//
//  GameViewController.swift
//  mySqure
//
//  Created by Ming Jing on 17/3/21.
//  Copyright © 2017年 Ming Jing. All rights reserved.
//  Swiftris  tetris
// http://blog.csdn.net/u011156012/article/details/43565483
// https://www.bloc.io/tutorials/swiftris-build-your-first-ios-game-with-swift#!/chapters/687
import UIKit
import SpriteKit


//class GameViewController: UIViewController {
// It's time to have GameViewController implement SwiftrisDelegate and begin reacting to changes in Swiftris' state:
// 将我们之前自定义的协议和GameViewController联系起来了
//class GameViewController: UIViewController, SwiftrisDelegate {

// assign the GameViewController as the tap gesture recognizer's delegate, much like how GameViewController is the Swiftris class' delegate
class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    
    // member variable : name is scene, its type is GameScene
    var scene: GameScene!
    
    
    var swiftris:Swiftris!
    
    // keep track of the last point on the screen at which a shape movement occurred or where a pan begins

    var panPointReference:CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!

    @IBOutlet weak var restartBtn: UIButton!
    @IBOutlet weak var top10Btn: UIButton!
    
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var downBtn: UIButton!
    @IBOutlet weak var turnBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        scene = GameScene(size: skView.bounds.size)
        
        scene.scaleMode = .aspectFill
        
        // #13
        scene.tick = didTick
        
        swiftris = Swiftris()
        
        swiftris.delegate = self
        
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
        leftBtn.clipsToBounds = true;
        leftBtn.layer.cornerRadius = leftBtn.layer.frame.size.width/10;
        
        downBtn.clipsToBounds = true;
        downBtn.layer.cornerRadius = downBtn.layer.frame.size.width/10;
        
        turnBtn.clipsToBounds = true;
        turnBtn.layer.cornerRadius = turnBtn.layer.frame.size.width/10;
        
        rightBtn.clipsToBounds = true;
        rightBtn.layer.cornerRadius = rightBtn.layer.frame.size.width/10;
        
        restartBtn.clipsToBounds = true;
        restartBtn.layer.cornerRadius = restartBtn.layer.frame.size.width/2;
        
        top10Btn.clipsToBounds = true;
        top10Btn.layer.cornerRadius = top10Btn.layer.frame.size.width/2;
        
        // #14
        
/*        scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {

            self.swiftris.nextShape?.moveTo(column: StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(shape: self.swiftris.nextShape!) {
                let nextShapes = self.swiftris.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(shape: nextShapes.nextShape!) {}
            }
        }
 */
 }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // #15
    func didTick() {
        
        swiftris.letShapeFall()
        
        //swiftris.fallingShape?.lowerShapeByOneRow()
        //scene.redrawShape(shape: swiftris.fallingShape!, completion: {})
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.movePreviewShape(shape: fallingShape) {
            
            // #16 a boolean which allows us to shut down interaction with the view
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        
        // hook up our logic and scene together
        levelLabel.text = "\(swiftris.level)"
        scoreLabel.text = "\(swiftris.score)"
        
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        
        view.isUserInteractionEnabled = false
        
        //scene.stopTicking()
        
        scene.playSound(sound: "Sounds/gameover.mp3")
        
        scene.animateCollapsingLines(linesToRemove: swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()) {
            
            // ???? Click restart button, then restart...
            // It should, but ??
            swiftris.beginGame()
        }
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        
        levelLabel.text = "\(swiftris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound(sound: "Sounds/levelup.mp3")
    }
    
    // stop the ticks, redraw the shape at its new location and then let it drop. This will in turn call back to GameViewController and report that the shape has landed.
    func gameShapeDidDrop(swiftris: Swiftris) {
        
        scene.stopTicking()
        scene.redrawShape(shape: swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        
        scene.playSound(sound: "Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        
        self.view.isUserInteractionEnabled = false
        // #10
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #11
                self.gameShapeDidLand(swiftris: swiftris)
            }
            scene.playSound(sound: "Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #17
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(shape: swiftris.fallingShape!) {}
    }
    
    
    @IBAction func leftBtnClicked(_ sender: Any) {
        swiftris.moveShapeLeft()
    }
    
    
    @IBAction func rightBtnClicked(_ sender: Any) {
        swiftris.moveShapeRight()
    }
    
    @IBAction func turnBtnClicked(_ sender: Any) {
        // Rotate:
        swiftris.rotateShape()
    }
    
    
    @IBAction func downBtnClicked(_ sender: Any) {
        swiftris.dropShape()
    }
    
    // Restart Button :
    @IBAction func restartBtn(_ sender: Any) {
        
        // hook up our logic and scene together
//        levelLabel.text = "\(swiftris.level)"
//        scoreLabel.text = "\(swiftris.score)"
//        
//        scene.tickLengthMillis = TickLengthLevelOne
//        
//        swiftris.endGame()
//        swiftris.beginGame()
    }
    
    
    // three UIGestureRecognizer objects : Tap, Pan, Swipe and their actions
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        
        swiftris.dropShape()
    }
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        
        // Tap and Rotate:
        swiftris.rotateShape()
    }
    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        
        // #2  we recover a point which defines the translation of the gesture relative to where it began.
        // This is not an absolute coordinate, just a measure of the distance that the user's finger has traveled
        
        let currentPoint = sender.translation(in: self.view)
        if let originalPoint = panPointReference {
            
            // #3
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                
                // #4  a positive velocity represents a gesture moving towards the right side of the screen, negative towards the left.
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    
    // allow each gesture recognizer to work in tandem with the others.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // #6  Sometimes when swiping down, a pan gesture may occur simultaneously with a swipe gesture. In order for these recognizers to relinquish priority, we will implement another optional delegate method at #6. The code performs is conditionals. These conditionals check whether the generic UIGestureRecognizer parameters is of the specific types of recognizers we expect to see. If the check succeeds, we execute the code block.
    
    //  lets the pan gesture recognizer take precedence over the swipe gesture and the tap to do likewise over the pan
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UISwipeGestureRecognizer {
            
            // Check Swipe
            if otherGestureRecognizer is UIPanGestureRecognizer {
                
                // Pan
                // ?? return true
                return false
// 如果当前手势是swipe而panRec 手势是otherGestureRecognizer时，在我的代码里面需要return false， 因为我刚开始发现如果是return ture，那么swipe手势一直没法识别，因为它被pan覆盖掉了。而改成false后就正常了
                
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            
            if otherGestureRecognizer is UITapGestureRecognizer {
                // Tap
                return true
            }
        }
        
        return false
    }
}
