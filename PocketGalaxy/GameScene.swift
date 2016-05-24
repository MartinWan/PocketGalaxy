//
//  GameScene.swift
//  PocketGalaxy
//
//  Created by Martin  on 2016-04-08.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var particles = Array<Particle>()
    var root = QuadrantNode(topRight: CGPoint(), bottomLeft: CGPoint()) // temp fix to avoid use of game scene initializers
    
    override func didMoveToView(view: SKView) {
        
        let sceneTopRight = CGPoint(x: size.width , y: size.height)
        let sceneBottomleft = CGPoint(x: 0, y: 0)
        root = QuadrantNode(topRight: sceneTopRight, bottomLeft: sceneBottomleft)

        physicsWorld.contactDelegate = self
    
        
        let particle = Particle()
        particle.position = CGPoint(x: 0, y: 0) // SW
        root.insert(particle)
        
        let particle1 = Particle()
        particle.position = CGPoint(x: 1, y: 1) // SW
        root.insert(particle1)
        
        
        print ("test")
        
        /*
        let N = 10
        let M = CGFloat(N) * Particle().mass
        
        for _ in 1...N {
            
            let particle = Particle()
            
            // generate R from exponential distribution
            let u = Float(arc4random()) / Float(UINT32_MAX)
            let lambda = Float(0.01)
            let R = -log(1.0 - u) / lambda
            
            // generate random angle
            let angle = Float(arc4random()) % Float(2 * M_PI)
            
            // init particle position
            let rx = R * cos(Float(angle)) + Float(size.width / 2)
            let ry = R * sin(Float(angle)) + Float(size.height / 2)
            particle.position = CGPoint(x: Int(rx), y: Int(ry))
            
            // init particle velocity
            let V = sqrt(M / CGFloat(R))
            let vx = -V * CGFloat(sin(angle))
            let vy = V * CGFloat(cos(angle))
            particle.velocity = CGVector(dx: Double(vx), dy: Double(vy))
            
            root.insert(particle)
            
            // add particle to scene
            particles.append(particle)
            self.addChild(particle)
        }
        
        */
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
       // intentionally blank for now
    }

    override func update(currentTime: NSTimeInterval) {
        
        let epsilon = CGFloat(0.01) // for singularity softening
        let h = CGFloat(0.01) // size of runge kutta h-step, error is O(h^4)
        var newParticleVelocities = Dictionary<Particle, CGVector>()
        
        // TODO: for erase below, for all particles: calculate force due to other particles 
        // i.e. for all particles: root.getForceOnParticle(particle) -> change-list[particle]
        // then ... for all changes, update particles in scene
        
        // calculate new particle velocities
        for particle in particles {
            var gx = CGFloat(0)
            var gy = CGFloat(0)
            
            // calculate g due to other particles
            for otherParticle in particles {
                if particle == otherParticle { // skip if same particle
                    continue
                }
                let mass = otherParticle.mass
                let Rx = otherParticle.position.x - particle.position.x
                let Ry = otherParticle.position.y - particle.position.y
                let R = sqrt(Rx * Rx + Ry * Ry)
   
                gx += (mass * Rx) / (R * R * R + epsilon)
                gy += (mass * Ry) / (R * R * R + epsilon)
            }
            // calculate particle's new velocity
            let vx = particle.velocity.dx + h * gx
            let vy = particle.velocity.dy + h * gy
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
