//
//  GameViewController.swift
//  HitTheTree
//
//  Created by punyawee  on 14/8/61.
//  Copyright © พ.ศ. 2561 Punyugi. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var mainScene: SCNScene?
    var mainView: SCNView?
    var ballNode: SCNNode?
    var cameraStickNode: SCNNode?
    var motion = MotionHelper()
    var motionForce = SCNVector3(0, 0, 0)
    var sounds: [String:SCNAudioSource] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupSounds()
        setupNodes()
    }
    
    private func setupScene() {
        mainView = view as? SCNView
        mainScene = SCNScene(named: "art.scnassets/mainScene.scn")
        mainScene?.physicsWorld.contactDelegate = self
        mainView?.scene = mainScene
        mainView?.delegate = self
        
        let tapRecog = UITapGestureRecognizer(target: self, action: #selector(sceneViewTapped(recognizer:)))
        tapRecog.numberOfTapsRequired = 1
        tapRecog.numberOfTouchesRequired = 1
        mainView?.addGestureRecognizer(tapRecog)
    }
    
    private func setupNodes() {
        ballNode = mainScene?.rootNode.childNode(withName: "ball", recursively: true)
        ballNode?.physicsBody?.contactTestBitMask = 2
        cameraStickNode = mainScene?.rootNode.childNode(withName: "cameraStick", recursively: true)
    }
    
    private func setupSounds() {
        
        if
            let sawSound = SCNAudioSource(fileNamed: "chainsaw.wav"),
            let jumpSound = SCNAudioSource(fileNamed: "jump.wav") {
            sawSound.load()
            jumpSound.load()
            sawSound.volume = 0.3
            jumpSound.volume = 0.4
            sounds["saw"] = sawSound
            sounds["jump"] = jumpSound
        }
        if let backgroundSound = SCNAudioSource(fileNamed: "background.mp3") {
            backgroundSound.volume = 0.3
            backgroundSound.loops = true
            backgroundSound.load()
            let backgroundPlayer = SCNAudioPlayer(source: backgroundSound)
            ballNode?.addAudioPlayer(backgroundPlayer)
        }
    }
    
    @objc private func sceneViewTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: mainView)
        let hitResults = mainView?.hitTest(location, options: nil)
        if let results = hitResults, let node = results.first?.node, node.name == "ball" {
            let jumpSound = sounds["jump"]!
            ballNode?.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
            ballNode?.physicsBody?.applyForce(SCNVector3(0, 3, -2), asImpulse: true)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let ball = ballNode?.presentation
        let ballPosition = ball?.position
        if let ballPosition = ballPosition {
            let targetPosition = SCNVector3(ballPosition.x, ballPosition.y + 5, ballPosition.z + 5)
            let cameraPosition = cameraStickNode?.position
            let camDamping:Float = 0.3
            if let cameraPosition = cameraPosition {
                let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
                let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
                let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping
                cameraStickNode?.position = SCNVector3(xComponent, yComponent, zComponent)
            }
        }
        motion.getAccelerometerData { (x, y, z) in
            self.motionForce = SCNVector3(x * 0.05, 0, (y + 0.8) * -0.05 )
        }
        ballNode?.physicsBody?.velocity += motionForce
    }
}

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.name == "tree" && contact.nodeB.name == "ball" {
            contact.nodeA.isHidden = true
            let saw = sounds["saw"]!
            ballNode?.runAction(SCNAction.playAudio(saw, waitForCompletion: false))
            let wait = SCNAction.wait(duration: 15)
            let unHideAction = SCNAction.run { (node) in
                node.isHidden = false
            }
            let actionSequence = SCNAction.sequence([wait, unHideAction])
            contact.nodeA.runAction(actionSequence)
        }
    }
}
