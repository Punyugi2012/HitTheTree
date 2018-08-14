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

    override func viewDidLoad() {
        super.viewDidLoad()
        if let scnView = view as? SCNView {
            let mainScene = SCNScene(named: "art.scnassets/mainScene.scn")
            scnView.allowsCameraControl = true
            scnView.scene = mainScene
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
