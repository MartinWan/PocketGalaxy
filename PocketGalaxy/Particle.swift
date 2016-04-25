//
//  Particle.swift
//  PocketGalaxy
//
//  Created by Martin  on 2016-04-16.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

// an SKSpriteNode with velocity and mass attributes
// (which allows more precise physics than using SKSpriteNode the physicsBody attribute)

class Particle: SKSpriteNode {
    
    var velocity = CGVector()
    var mass = CGFloat(20000)
    
    init() {
        let texture = SKTexture(imageNamed: "particle")
        let size = CGSize(width: 10, height: 10)
        super.init(texture: texture, color: SKColor.clearColor(), size: size)
        
        physicsBody = SKPhysicsBody(circleOfRadius: 1)
        physicsBody!.contactTestBitMask = physicsBody!.collisionBitMask
        physicsBody!.restitution = 0.1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

