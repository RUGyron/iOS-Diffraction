//
//  ViewController.swift
//  Prism Refraction
//
//  Created by Alexey Voronov on 26/05/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, SKViewDelegate, SKSceneDelegate {
    
    var scene: SKScene = SKScene(size: .zero)
    var nowangle: CGFloat = .pi / 2
    
    var t1x = CGFloat()
    var t1y = CGFloat()
    var t2x = CGFloat()
    var t2y = CGFloat()
    var t1h = Int()
    var t2h = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sceneView = SKView(frame: self.view.bounds)
        scene = SKScene(size: sceneView.bounds.size)
        scene.backgroundColor = .black
        scene.delegate = self
        sceneView.isMultipleTouchEnabled = true
        sceneView.presentScene(scene)
        sceneView.showsFPS = true
        sceneView.showsPhysics = false
        self.view.addSubview(sceneView)

        
        addWall(a: CGPoint(x: 325, y: 300), b: CGPoint(x: 50, y: 300))
        addWall(a: CGPoint(x: 325, y: 200), b: CGPoint(x: 50, y: 200))
        
        addWall(a: CGPoint(x: 325, y: 300), b: CGPoint(x: 325, y: 200))
        addWall(a: CGPoint(x: 50, y: 300), b: CGPoint(x: 50, y: 200))
        
        addWall(a: CGPoint(x: 325, y: 600), b: CGPoint(x: 50, y: 600))
        addWall(a: CGPoint(x: 325, y: 500), b: CGPoint(x: 50, y: 500))
        
        addWall(a: CGPoint(x: 325, y: 600), b: CGPoint(x: 325, y: 500))
        addWall(a: CGPoint(x: 50, y: 600), b: CGPoint(x: 50, y: 500))
        
        addWall(a: CGPoint(x: 50, y: 400), b: CGPoint(x: 375/2, y: 450))
        addWall(a: CGPoint(x: 375/2, y: 450), b: CGPoint(x: 325, y: 400))
        addWall(a: CGPoint(x: 325, y: 400), b: CGPoint(x: 375/2, y: 350))
        addWall(a: CGPoint(x: 375/2, y: 350), b: CGPoint(x: 50, y: 400))
        
    }
    
    func removeNodeByName(name: String) {
        for node in scene.children {
            if node.name == name {
                node.removeFromParent()
            }
        }
    }
    
    func addWall(a: CGPoint, b: CGPoint) {
        let yourline = SKShapeNode()
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: a)
        pathToDraw.addLine(to: b)
        yourline.path = pathToDraw
        yourline.strokeColor = .gray
        yourline.name = "wall"
        yourline.glowWidth = 1.0
        yourline.physicsBody = SKPhysicsBody(edgeFrom: a, to: b)
        yourline.physicsBody?.isDynamic = false
        scene.addChild(yourline)
    }
    
    func addLine(a: CGPoint, b: CGPoint, hue: CGFloat) {
        if a != b && !a.x.isNaN && !a.y.isNaN && !b.x.isNaN && !b.y.isNaN {
            let yourline = SKShapeNode()
            let pathToDraw = CGMutablePath()
            pathToDraw.move(to: a)
            pathToDraw.addLine(to: b)
            yourline.path = pathToDraw
            yourline.strokeColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 0.3)
            yourline.name = "ray"
            yourline.blendMode = .add
            yourline.glowWidth = 1.0
            scene.addChild(yourline)
        }
    }
    
    func startRay(point: CGPoint, angle: CGFloat, spectr: CGFloat, inside: Bool = false, index: Int = 0) {
        if index > 6 { return }
        var angle_point = CGPoint(x: 1000 * cos(angle) + point.x, y: 1000 * sin(angle) + point.y)
        
        let correctedPoint = CGPoint(x: point.x + 1000 * cos(angle) * 0.002, y: point.y + 1000 * sin(angle) * 0.002)
        var isFound = false
        scene.physicsWorld.enumerateBodies(alongRayStart: correctedPoint, end: angle_point) { (body, collpoint, vector, pointer) in
            if !isFound {
                isFound = true
                angle_point = collpoint
                
                let angleNormal = atan2(vector.dy, vector.dx)
                
                let angleA = angleNormal - fmod(angle, .pi * 2)
                var angleB: CGFloat = 0.0
                if !inside {
                    angleB = asin(sin(angleA) / 1.33) * ((0.857 - spectr) * 0.2 + 0.8)
                } else {
                    angleB = asin(sin(angleA) * 1.33) * 1/((0.857 - spectr) * 0.2 + 0.8)
                }
                
                let currentAngle: CGFloat = angleNormal + .pi + angleB
                self.startRay(point: collpoint, angle: currentAngle, spectr: spectr, inside: !inside, index: index + 1)
            }
        }
        self.addLine(a: point, b: angle_point, hue: spectr)
    }
    
    func addPoint(point: CGPoint, num: Int) {
        let circle = SKShapeNode(circleOfRadius: 30 )
        circle.position = point
        circle.strokeColor = SKColor.black
        circle.glowWidth = 2.0
        circle.name = "point\(num)"
        circle.fillColor = SKColor.orange
        scene.addChild(circle)
    }
    
    func updatePoint(num: Int) {
        removeNodeByName(name: "point\(num)")
        if num == 1 {
            addPoint(point: CGPoint(x: t1x, y: t1y), num: 1)
        } else if num == 2 {
            addPoint(point: CGPoint(x: t2x, y: t2y), num: 2)
        }
    }
    
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        // updateScene()
    }
    
    func updateScene(point: CGPoint) {
        removeNodeByName(name: "ray")
        for i in 0...30 {
            startRay(point: point, angle: nowangle, spectr: CGFloat(i) / 35)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.hash == t1h {
                t1h = 0
                removeNodeByName(name: "point1")
            } else if touch.hash == t2h {
                t2h = 0
                removeNodeByName(name: "point2")
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // state is needed to define if touch is 1 or 2 (2 = true)
        var state:Bool = false
        
        for touch in touches {
            if t1h != 0 && touch.hash != t1h {
                state = true
            }
        }
        
        if state {
            // second tap
            // both are moving
            if touches.count == 2 {
                for touch in touches {
                    if touch.hash == t1h {
                        t1x = touch.preciseLocation(in: self.view).x
                        t1y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                        updateScene(point: CGPoint(x: t1x, y: t1y))
                    } else {
                        t2h = touch.hash
                        t2x = touch.preciseLocation(in: self.view).x
                        t2y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                        // changing an angle
                        nowangle = atan((t2y - t1y) / (t2x - t1x))
                        if (t2x - t1x) < 0 {
                            nowangle += .pi
                        }
                        updateScene(point: CGPoint(x: t1x, y: t1y))
                    }
                }
                // tap1 touched but is not moving, tap2 choosen
            } else if touches.count == 1 {
                for touch in touches {
                    // tap2 in move
                    if touch.hash == t2h {
                        t2x = touch.preciseLocation(in: self.view).x
                        t2y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                    // tap2 just touched
                    } else if t2h == 0 {
                        t2h = touch.hash
                        t2x = touch.preciseLocation(in: self.view).x
                        t2y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                    }
                    // changing an angle
                    nowangle = atan((t2y - t1y) / (t2x - t1x))
                    if (t2x - t1x) < 0 {
                        nowangle += .pi
                    }
                    updateScene(point: CGPoint(x: t1x, y: t1y))
                }
            }
            updatePoint(num: 1)
            updatePoint(num: 2)
        } else if t1h == 0 {
            // tap1 choosen (start)
            for touch in touches {
                t1h = touch.hash
                t1x = touch.preciseLocation(in: self.view).x
                t1y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                updateScene(point: CGPoint(x: t1x, y: t1y))
                updatePoint(num: 1)
                for node in scene.children {
                    if node.name == "point2" {
                        removeNodeByName(name: "point2")
                    }
                }
            }
        } else if t1h != 0 && touches.first?.hash == t1h {
            // 2 taps but tap1 is choosen
            for touch in touches {
                t1x = touch.preciseLocation(in: self.view).x
                t1y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                // changing an angle
                nowangle = atan((t2y - t1y) / (t2x - t1x))
                if (t2x - t1x) < 0 {
                    nowangle += .pi
                }
                updateScene(point: CGPoint(x: t1x, y: t1y))
                updatePoint(num: 1)
                for node in scene.children {
                    if node.name == "point2" {
                        updatePoint(num: 2)
                    }
                }
            }
        }
    }
}
