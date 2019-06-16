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
    var raysCount: Int = 0
    var rayGlowWidth: CGFloat = 2.0
    var rayStrokeColor = UIColor(hue: 0.0, saturation: 4.0, brightness: 4.0, alpha: 1.0)
//    GUI
    var navBar = UISegmentedControl(items: ["Лучи", "Среды"])
    var formBar = UISegmentedControl(items: ["Ромб", "Треугольник", "Квадрат", "Выпуклая", "Вогнутая"])
    var rayBar = UISegmentedControl(items: ["1 луч", "Спектр"])
    var slider = UISlider()
    var label = UILabel()
    var deleteBtn = UIButton()
    var currentNode : SKNode?
    var background = SKSpriteNode(imageNamed: "background.png")
    
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
        background.position = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        background.size = self.view.frame.size
        background.yScale = 0.2
        background.xScale = 0.9
        background.alpha = 0.3
        background.name = "background"
//        background.frame = CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2, width: 250, height: 150)
        
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
        formBar.isHidden = true
        
        rayBar.selectedSegmentIndex = 0
        rayBar.frame = CGRect(x: 10, y: self.view.frame.size.height - 100, width: self.view.frame.size.width - 20, height: 30)
        rayBar.layer.cornerRadius = 5.0
        rayBar.backgroundColor = UIColor.black
        rayBar.tintColor = UIColor.white
        rayBar.isHidden = false
        rayBar.addTarget(self, action: #selector(rayChanger), for: .valueChanged)
        
        scene.addChild(background)
        self.view.addSubview(navBar)
        self.view.addSubview(slider)
        self.view.addSubview(label)
        self.view.addSubview(deleteBtn)
        self.view.addSubview(formBar)
        self.view.addSubview(rayBar)
    }
    
    func addFigure(id: Int, pos: CGPoint, n: Float) -> SKShapeNode {
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
        case 3:
            let radius = 30.0
            path.move(to: CGPoint(x: cos(0.3) * radius * 4, y: sin(0.3) * radius))
            for radians in stride(from: 0.0 + 0.3, to: .pi - 0.3, by: .pi / 300) {
                let pos = CGPoint(x: cos(radians) * radius * 4, y: sin(radians) * radius)
                path.addLine(to: pos)
            }
            for radians in stride(from: 0.0 + 0.3 + .pi, to: .pi * 2 - 0.3, by: .pi / 300) {
                let pos = CGPoint(x: cos(radians) * radius * 4, y: sin(radians) * radius)
                path.addLine(to: pos)
            }
            path.close()
        case 4:
            let radius = 30.0
            path.move(to: CGPoint(x: cos(0.3) * radius * 4, y: sin(0.3) * radius - 40))
            for radians in stride(from: 0.0 + 0.3, to: .pi - 0.3, by: .pi / 100) {
                let pos = CGPoint(x: cos(radians) * radius * 4, y: sin(radians) * radius - 40)
                path.addLine(to: pos)
            }
            for radians in stride(from: 0.0 + 0.3 + .pi, to: .pi * 2 - 0.3, by: .pi / 100) {
                let pos = CGPoint(x: cos(radians) * radius * 4, y: sin(radians) * radius + 40)
                path.addLine(to: pos)
            }
            path.close()
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
        return figure
    }
    
    func removeNodeByName(name: String) {
        for node in scene.children {
            if node.name == "background" {continue}
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
            rayBar.isHidden = false
        case 1:
            slider.isHidden = false
            label.isHidden = false
            formBar.isHidden = false
            rayBar.isHidden = true
        default:
            fatalError()
        }
    }
    
    @objc func rayChanger() {
        switch rayBar.selectedSegmentIndex {
        case 0:
            raysCount = 0
            rayGlowWidth = 2.0
        case 1:
            raysCount = 30
            rayGlowWidth = 1.0
        default:
            fatalError()
        }
        updateScene(point: CGPoint(x: t1x, y: t1y))
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
            if rayBar.selectedSegmentIndex == 0 {
                yourline.strokeColor = rayStrokeColor
            } else {
                yourline.strokeColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 0.3)
            }
            yourline.name = "ray"
            yourline.blendMode = .add
            yourline.glowWidth = rayGlowWidth
            scene.addChild(yourline)
        }
    }
    
    func startRay(point: CGPoint, angle: CGFloat, spectr: CGFloat, index: Int = 0) {
        if index > 30 { return }
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
//                print(self.inside)
                let betweenPoint = CGPoint(x: (point.x + collpoint.x)/2, y: (point.y + collpoint.y)/2)
                self.updateInside(point: betweenPoint)
                if !self.inside {
//                    self.inside = true
                    angleB = asin(sin(angleA) / n) * ((0.857 - spectr) * 0.2 + 0.8)
                } else {
                    angleB = asin(sin(angleA) * n) * 1/((0.857 - spectr) * 0.2 + 0.8)
                    if angleB.isNaN {
                        angleB = angleA
//                        for corner in self.corners {
//                            print(abs(corner.x - collpoint.x), abs(corner.y - collpoint.y))
//                            if abs(corner.x - collpoint.x) < 10 && abs(corner.y - collpoint.y) < 10 {
//                                self.inside = false
//                                break
//                            }
//                        }
                    } else {
//                        self.inside = false
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
            if node.name == "ray" || node.name == "point1" || node.name == "point2" || node.name == "background" {continue}
            if node.contains(point) {
                self.inside = true
                break
            }
        }
    }
    
    func updateScene(point: CGPoint) {
        removeNodeByName(name: "ray")
        for i in 0...raysCount {
            updateInside(point: point)
            startRay(point: point, angle: nowangle, spectr: CGFloat(i) / 35)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
                let cur_nodes = self.scene.nodes(at: location)
                var local_state = false
                for node in cur_nodes {
                    if node.name != "ray" && node.name != "background" {local_state = true}
                }
                if !local_state {
                    let x = touch.preciseLocation(in: self.view).x
                    let y = self.view.frame.size.height - touch.preciseLocation(in: self.view).y
                    let formId = formBar.selectedSegmentIndex
                    let node = addFigure(id: formId, pos: CGPoint(x: x, y: y), n: optical_n)
//                    for n in scene.children {
//                        if n == node || n.name == "ray" {continue}
//                        if n.intersects(node) {
//                            node.removeFromParent()
//                            break
//                        }
//                    }
                    updateScene(point: CGPoint(x: t1x, y: t1y))
                }
                let touchedNodes = self.scene.nodes(at: location)
                for node in touchedNodes.reversed() {
                    if node.name == "draggable" {
                        self.currentNode = node
                    }
                }
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
                let nodeLocation = node.position
                node.position = touchLocation
                updateScene(point: CGPoint(x: t1x, y: t1y))
//                for n in scene.children {
//                    if n == node || n.name == "ray" {continue}
//                    if !n.intersects(node) {
//                        updateScene(point: CGPoint(x: t1x, y: t1y))
//                    } else {
//                        node.position = nodeLocation
//                        updateScene(point: CGPoint(x: t1x, y: t1y))
//                    }
//                }
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
