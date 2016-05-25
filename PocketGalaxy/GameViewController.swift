//
//  GameViewController.swift
//  PocketGalaxy
//
//  Created by Martin  on 2016-04-06.
//  Copyright (c) 2016 Martin . All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view as! SKView!
            scene.scaleMode = .AspectFit
            skView.presentScene(scene)
        }
    }
    
}