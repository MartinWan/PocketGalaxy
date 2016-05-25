//
//  GameScene.swift
//  PocketGalaxy
//
//  Created by Martin  on 2016-04-08.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

var MIN_QUADRANT_HEIGHT = CGFloat() // minimum size for quadrant subdivision; divice-specific; set in game scene initialization
let EPSILON = CGFloat(0.1) // constant for singularity softening


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var particles = Array<Particle>()
    var root = QuadrantNode(topRight: CGPoint(), bottomLeft: CGPoint())
    
    override func didMoveToView(view: SKView) {
        
        MIN_QUADRANT_HEIGHT = size.height / 16.0
        physicsWorld.contactDelegate = self
        
        // initialize root
        let sceneTopRight = CGPoint(x: size.width , y: size.height)
        let sceneBottomleft = CGPoint(x: 0, y: 0)
        root = QuadrantNode(topRight: sceneTopRight, bottomLeft: sceneBottomleft)
        
        let N = 10
        for _ in 1...N {
            
            // generate R from exponential distribution
            let u = Float(arc4random()) / Float(UINT32_MAX)
            let lambda = Float(0.001)
            let R = -log(1.0 - u) / lambda
            
            // generate random angle
            let angle = 2.0 * Float(M_PI) * Float(arc4random()) / Float(UINT32_MAX)
            
            // init particle position
            let rx = R * cos(angle) + Float(size.width / 2)
            let ry = R * sin(angle) + Float(size.height / 2)
            let particle = Particle(posX: rx, posY: ry)
            
            /* init particle velocity
            let M = particle.mass * CGFloat(N) // total mass
            let V = sqrt(M / CGFloat(sqrt(R))) * 0.1
            let vx = -V * CGFloat(sin(angle))
            let vy = V * CGFloat(cos(angle))
            particle.velocity = CGVector(dx: Double(vx), dy: Double(vy)) */
            
            particles.append(particle)
            root.insert(particle)
            self.addChild(particle)
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
       // intentionally blank
    }

    override func update(currentTime: NSTimeInterval) {
        
        let h = CGFloat(0.1) // size of h-step in numerical integration (euler's method for now)
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
