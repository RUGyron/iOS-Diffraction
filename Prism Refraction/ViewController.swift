//
//  ViewController.swift
//  Prism Refraction
//
//  Created by Vladislav Pivosh on 26/05/2019.
//  Copyright © 2019 Vladislav Pivosh. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController, SKViewDelegate, SKSceneDelegate {
    
    var scene: SKScene = SKScene(size: .zero)
    var nowangle: CGFloat = .pi
    var optical_n: Float = 1.0
    
//    Mechanics
    var t1x = CGFloat()
    var t1y = CGFloat()
    var t2x = CGFloat()
    var t2y = CGFloat()
    var t1h = Int()
    var t2h = Int()
    var rects = [[[CGFloat]]]()
    var inside = false
    var corners = [CGPoint]()
//    GUI
    var navBar = UISegmentedControl(items: ["Лучи", "Перемещение", "Среды"])
    var formBar = UISegmentedControl(items: ["Ромб", "Треугольник", "Квадрат"])
    var slider = UISlider()
    var label = UILabel()
    var deleteBtn = UIButton()
    var currentNode : SKNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sceneView = SKView(frame: self.view.bounds)
        scene = SKScene(size: sceneView.bounds.size)
        scene.backgroundColor = .black
        scene.delegate = self
        sceneView.isMultipleTouchEnabled = true
        sceneView.presentScene(scene)
        sceneView.showsFPS = false
        sceneView.showsPhysics = true
        self.view.addSubview(sceneView)
        setupInterface()
    }
    
    func setupInterface() {
        deleteBtn.frame = CGRect(x: 325/2, y: 100, width: 150, height: 30)
        deleteBtn.center.x = self.view.center.x
        deleteBtn.setTitle("Очистить", for: .normal)
        deleteBtn.addTarget(self, action: #selector(deletebtnPressed), for: .touchDown)
        
        slider.frame = CGRect(x: 50, y: self.view.frame.size.height - 150,  width: 275, height: 50)
        slider.minimumValue = 1.0003
        slider.maximumValue = 2.42
        slider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        slider.isHidden = true
        
        label.frame = CGRect(x: 175, y: self.view.frame.size.height - 200, width: 100, height: 50)
        label.textColor = .white
        label.text = "\(slider.value)"
        label.isHidden = true
        
        navBar.selectedSegmentIndex = 0
        navBar.frame = CGRect(x: 10, y: 50, width: self.view.frame.size.width - 20, height: 30)
        navBar.layer.cornerRadius = 5.0
        navBar.backgroundColor = UIColor.black
        navBar.tintColor = UIColor.white
        navBar.addTarget(self, action: #selector(navigator), for: .valueChanged)
        
        formBar.selectedSegmentIndex = 0
        formBar.frame = CGRect(x: 10, y: self.view.frame.size.height - 100, width: self.view.frame.size.width - 20, height: 30)
        formBar.layer.cornerRadius = 5.0
        formBar.backgroundColor = UIColor.black
        formBar.tintColor = UIColor.white
        formBar.addTarget(self, action: #selector(former), for: .valueChanged)
        formBar.isHidden = true
        
        self.view.addSubview(navBar)
        self.view.addSubview(slider)
        self.view.addSubview(label)
        self.view.addSubview(deleteBtn)
        self.view.addSubview(formBar)
    }
    
    func addFigure(id: Int, pos: CGPoint, n: Float) {
        let figure = SKShapeNode()
        let path = UIBezierPath()
        
        switch id {
        case 0:
            path.move(to: CGPoint(x: -100, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 50))
            path.addLine(to: CGPoint(x: 100, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -50))
            path.close()
            corners.append(CGPoint(x: -100 + pos.x, y: 0 + pos.y))
            corners.append(CGPoint(x: 0 + pos.x, y: 50 + pos.y))
            corners.append(CGPoint(x: 100 + pos.x, y: 0 + pos.y))
            corners.append(CGPoint(x: 0 + pos.x, y: -50 + pos.y))
        case 1:
            path.move(to: CGPoint(x: -100, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 75))
            path.addLine(to: CGPoint(x: 100, y: 0))
            path.close()
            corners.append(CGPoint(x: -100 + pos.x, y: 0 + pos.y))
            corners.append(CGPoint(x: 0 + pos.x, y: 75 + pos.y))
            corners.append(CGPoint(x: 100 + pos.x, y: 0 + pos.y))
        case 2:
            path.move(to: CGPoint(x: -75, y: -75))
            path.addLine(to: CGPoint(x: -75, y: 75))
            path.addLine(to: CGPoint(x: 75, y: 75))
            path.addLine(to: CGPoint(x: 75, y: -75))
            path.close()
            corners.append(CGPoint(x: -75 + pos.x, y: -75 + pos.y))
            corners.append(CGPoint(x: -75 + pos.x, y: 75 + pos.y))
            corners.append(CGPoint(x: 75 + pos.x, y: 75 + pos.y))
            corners.append(CGPoint(x: 75 + pos.x, y: -75 + pos.y))
        default:
            path.move(to: CGPoint(x: -100, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 50))
            path.addLine(to: CGPoint(x: 100, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 50))
            path.close()
            corners.append(CGPoint(x: -100 + pos.x, y: 0 + pos.y))
            corners.append(CGPoint(x: 0 + pos.x, y: 50 + pos.y))
            corners.append(CGPoint(x: 100 + pos.x, y: 0 + pos.y))
            corners.append(CGPoint(x: 0 + pos.x, y: 50 + pos.y))
            
        }
        
        figure.userData = ["n": n]
        figure.strokeColor = .gray
        figure.glowWidth = 1.0
        
        figure.position = pos
        figure.name = "draggable"
        figure.path = path.cgPath
        
        figure.physicsBody = SKPhysicsBody(edgeLoopFrom: path.cgPath)
        figure.physicsBody?.isDynamic = false
        
        scene.addChild(figure)
    }
    
    func removeNodeByName(name: String) {
        for node in scene.children {
            switch name {
            case "*":
                node.removeFromParent()
            case node.name:
                node.removeFromParent()
            default:
                ()
            }
        }
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        let value = Float(round(10000*slider.value)/10000)
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                optical_n = value
                label.text = "\(value)"
            case .moved:
                optical_n = value
                label.text = "\(value)"
            case .ended:
                optical_n = value
                label.text = "\(value)"
            default:
                break
            }
        }
    }
    
    @objc func navigator() {
        switch navBar.selectedSegmentIndex {
        case 0:
            slider.isHidden = true
            label.isHidden = true
            formBar.isHidden = true
        case 1:
            slider.isHidden = true
            label.isHidden = true
            formBar.isHidden = true
        case 2:
            slider.isHidden = false
            label.isHidden = false
            formBar.isHidden = false
        default:
            fatalError()
        }
    }
    
    @objc func former() {
        switch formBar.selectedSegmentIndex {
        case 0:
            ()
        case 1:
            ()
        case 2:
            ()
        default:
            fatalError()
        }
    }
    
    @objc func deletebtnPressed() {
        removeNodeByName(name: "*")
        t1x = -50
        t1y = -50
        nowangle = 0
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
    
    func startRay(point: CGPoint, angle: CGFloat, spectr: CGFloat, index: Int = 0) {
        if index > 100 { return }
        var angle_point = CGPoint(x: 1000 * cos(angle) + point.x, y: 1000 * sin(angle) + point.y)
        
        let correctedPoint = CGPoint(x: point.x + 1000 * cos(angle) * 0.002, y: point.y + 1000 * sin(angle) * 0.002)
        var isFound = false
        scene.physicsWorld.enumerateBodies(alongRayStart: correctedPoint, end: angle_point) { (body, collpoint, vector, pointer) in
            if !isFound {
                isFound = true
                angle_point = collpoint
                var n = CGFloat()
                if body.node?.userData != nil {
                    n = body.node?.userData!["n"] as! CGFloat
                }
            
                let angleNormal = atan2(vector.dy, vector.dx)
                
                let angleA = angleNormal - fmod(angle, .pi * 2)
                var angleB: CGFloat = 0.0
                if !self.inside {
                    self.inside = true
                    angleB = asin(sin(angleA) / n) * ((0.857 - spectr) * 0.2 + 0.8)
                } else {
                    angleB = asin(sin(angleA) * n) * 1/((0.857 - spectr) * 0.2 + 0.8)
                    if angleB.isNaN {
                        angleB = angleA
                        if self.corners.contains(point) {
                            print("contains!")
                            self.inside = false
                        }
                    } else {
                        self.inside = false
                    }
                }
                let currentAngle: CGFloat = angleNormal + .pi + angleB
                self.startRay(point: collpoint, angle: currentAngle, spectr: spectr, index: index + 1)
            }
        }
        self.addLine(a: point, b: angle_point, hue: spectr)
    }
    
    func addPoint(point: CGPoint, num: Int) {
        let circle = SKShapeNode(circleOfRadius: 20 )
        circle.position = point
        circle.strokeColor = SKColor.black
        circle.glowWidth = 2.0
        circle.name = "point\(num)"
        circle.fillColor = SKColor.white
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
    
    func updateInside(point: CGPoint) {
        self.inside = false
        for node in scene.children {
            if node.name == "ray" || node.name == "point1" || node.name == "point2" {continue}
            if node.contains(point) {
                self.inside = true
                break
            }
        }
    }
    
    func updateScene(point: CGPoint) {
        removeNodeByName(name: "ray")
//        print("before")
        for i in 0...30 {
            updateInside(point: point)
            startRay(point: point, angle: nowangle, spectr: CGFloat(i) / 35)
            break
        }
//        print("after")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(navBar.selectedSegmentIndex)
        if navBar.selectedSegmentIndex == 0 {
            if touches.count == 2 {
                for touch in touches {
                    if t1h == 0 {
                        t1h = touch.hash
                        t1x = touch.preciseLocation(in: self.view).x
                        t1y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                        updateScene(point: CGPoint(x: t1x, y: t1y))
                    } else if t1h != 0 {
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
            } else if touches.count == 1 {
                for touch in touches {
                    if t1h != 0 {
                        t2h = touch.hash
                        t2x = touch.preciseLocation(in: self.view).x
                        t2y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                        // changing an angle
                        nowangle = atan((t2y - t1y) / (t2x - t1x))
                        if (t2x - t1x) < 0 {
                            nowangle += .pi
                        }
                        updateScene(point: CGPoint(x: t1x, y: t1y))
                    } else if t1h == 0 {
                        t1h = touch.hash
                        t1x = touch.preciseLocation(in: self.view).x
                        t1y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                        updateScene(point: CGPoint(x: t1x, y: t1y))
                    }
                }
            }
        } else if navBar.selectedSegmentIndex == 1 {
            if let touch = touches.first {
                let location = touch.location(in: self.scene)
                
                let touchedNodes = self.scene.nodes(at: location)
                for node in touchedNodes.reversed() {
                    if node.name == "draggable" {
                        self.currentNode = node
                    }
                }
            }
        } else if navBar.selectedSegmentIndex == 2 {
            for touch in touches {
                let x = touch.preciseLocation(in: self.view).x
                let y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                let formId = formBar.selectedSegmentIndex
                addFigure(id: formId, pos: CGPoint(x: x, y: y), n: optical_n)
                updateScene(point: CGPoint(x: t1x, y: t1y))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if navBar.selectedSegmentIndex == 0 {
            for touch in touches {
                if touch.hash == t1h {
                    t1h = 0
                    removeNodeByName(name: "point1")
                } else if touch.hash == t2h {
                    t2h = 0
                    removeNodeByName(name: "point2")
                }
            }
        } else if navBar.selectedSegmentIndex == 1 {
            self.currentNode = nil
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if navBar.selectedSegmentIndex == 1 {
            if let touch = touches.first, let node = self.currentNode {
                let touchLocation = touch.location(in: self.scene)
                node.position = touchLocation
                updateScene(point: CGPoint(x: t1x, y: t1y))
            }
            return
        } else if navBar.selectedSegmentIndex == 2 {
            for touch in touches {
                let x = touch.preciseLocation(in: self.view).x
                let y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
//                Creating figures here
                updateScene(point: CGPoint(x: t1x, y: t1y))
            }
            return
        }
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
                if touch.hash == t2h {
                    t2x = touch.preciseLocation(in: self.view).x
                    t2y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                    // changing an angle
                    nowangle = atan((t2y - t1y) / (t2x - t1x))
                    if (t2x - t1x) < 0 {
                        nowangle += .pi
                    }
                    updateScene(point: CGPoint(x: t1x, y: t1y))
                    updatePoint(num: 2)
                } else {
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
