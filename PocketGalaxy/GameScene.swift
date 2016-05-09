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
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        let N = 400
        for _ in 1...N {
            
            let particle = Particle()
            
            // generate R from exponential distribution, Vancouleur's law
            let u = Float(arc4random()) / Float(UINT32_MAX)
            let lambda = Float(0.001)
            let R = -log(1.0 - u) / lambda
            
            // generate random angle
            let angle = 2.0 * Float(M_PI) * Float(arc4random()) / Float(UINT32_MAX)
            
            let rx = R * cos(angle) + Float(size.width / 2)
            let ry = R * sin(angle) + Float(size.height / 2)
            print( rx, ry)
            particle.position = CGPoint(x: Int(rx), y: Int(ry))
            
            
            particles.append(particle)
            self.addChild(particle)
        }
 
        /* Two body orbit test
        let p1 = Particle()
        let p2 = Particle()
 
        p1.position = CGPoint(x: 300, y: 300)
        p2.position = CGPoint(x: 300, y: 400)
        p2.velocity = CGVector(dx: 100, dy: 0)
        p1.mass = pow(10, 6)
 
        particles.append(p1)
        particles.append(p2)
        self.addChild(p1)
        self.addChild(p2)
        */
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // TODO: implement proper inelastic collisions?
    }

    override func update(currentTime: NSTimeInterval) {
        
        
        let epsilon = CGFloat(0.01) // for singularity softening
        let h = CGFloat(0.01) // size of runge kutta h-step, error is O(h^4)
        var newParticleVelocities = Dictionary<Particle, CGVector>()
        
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
