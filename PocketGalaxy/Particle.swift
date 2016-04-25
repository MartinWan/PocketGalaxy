//
//  Particle.swift
//  PocketGalaxy
//
//  Created by Martin  on 2016-04-16.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

class Particle: SKSpriteNode {
    
    var velocity = CGVector()
    var mass = CGFloat(100)
    
    init() {
        let texture = SKTexture(imageNamed: "particle")
        let size = CGSize(width: 10, height: 10)
        super.init(texture: texture, color: SKColor.clearColor(), size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

