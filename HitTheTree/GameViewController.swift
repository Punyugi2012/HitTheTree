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
        setupNodes()
        setupScene()
        setupSounds()
    }
    
    private func setupScene() {
        mainView = view as? SCNView
        mainScene = SCNScene(named: "art.scnassets/mainScene.scn")
        mainView?.scene = mainScene
        mainView?.allowsCameraControl = true
    }
    
    private func setupNodes() {
        ballNode = mainScene?.rootNode.childNode(withName: "ball", recursively: true)
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
    
    private func sceneViewTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: mainView)
        let hitResults = mainView?.hitTest(location, options: nil)
        if let results = hitResults, let node = results.first?.node, node.name == "ball" {
            let jumpSound = sounds["jump"]!
            ballNode?.runAction(SCNAction.playAudio(jumpSound, waitForCompletion: false))
            ballNode?.physicsBody?.applyForce(SCNVector3(0, 5, -2), asImpulse: true)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
