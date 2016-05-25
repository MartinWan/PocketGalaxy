//
//  GameScene.swift
//  PocketGalaxy
//
//  Created by Martin  on 2016-04-08.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

var MIN_QUADRANT_HEIGHT = CGFloat() // minimum size for quadrant subdivision; divice-specific; set in game scene initialization


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var particles = Array<Particle>()
    var root = QuadrantNode(topRight: CGPoint(), bottomLeft: CGPoint())
    
    override func didMoveToView(view: SKView) {
        
        MIN_QUADRANT_HEIGHT = size.height / 4.0
        physicsWorld.contactDelegate = self
        
        // initialize root
        let sceneTopRight = CGPoint(x: size.width , y: size.height)
        let sceneBottomleft = CGPoint(x: 0, y: 0)
        root = QuadrantNode(topRight: sceneTopRight, bottomLeft: sceneBottomleft)
        
        let particle = Particle(posX: 0, posY: 0) // SW
        root.insert(particle)
        
        let particle1 = Particle(posX: 0, posY: size.height) // SE
        root.insert(particle1)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
       // intentionally blank
    }

    override func update(currentTime: NSTimeInterval) {
        
        let h = CGFloat(0.01) // size of h-step in numerical integration (euler's method for now)
        var newParticleVelocities = Dictionary<Particle, CGVector>()
        
        
        // calculate new particle velocities
        for particle in particles {

            let g = root.getFieldOnParticle(particle)
            let vx = particle.velocity.dx + h * g.dx
            let vy = particle.velocity.dy + h * g.dy
            
            newParticleVelocities[particle] = CGVector(dx: vx, dy: vy)
        }
        
        // update particle velocities and positions
        for particle in particles {
            let v = newParticleVelocities[particle]
            let rx = particle.position.x + v!.dx * h
            let ry = particle.position.y + v!.dy * h
            
            particle.velocity = v!
            particle.position = CGPoint(x: rx, y: ry)
        }
        
    }
    

}
