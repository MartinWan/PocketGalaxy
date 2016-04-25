//
//  GameScene.swift
//  PocketGalaxy
//
//  Created by Martin  on 2016-04-08.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var particles = Array<Particle>()
    
    override func didMoveToView(view: SKView) {
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
    }

    override func update(currentTime: NSTimeInterval) {
        
        let epsilon = CGFloat(0.00) // for singularity softening
        let h = CGFloat(0.01)
   //     var particleForces = Dictionary<Particle, CGVector>()
        
        for particle in particles {
            var gx = CGFloat(0)
            var gy = CGFloat(0)
            
            // calculate g due to other particles
            for otherParticle in particles {
                let mass = otherParticle.mass
                if particle == otherParticle { continue }
                let Rx = otherParticle.position.x - particle.position.x
                let Ry = otherParticle.position.y - particle.position.y
                let R = sqrt(Rx * Rx + Ry * Ry)
                
                gx += (mass * Rx) / (R * R * R + epsilon)
                gy += (mass * Ry) / (R * R * R + epsilon)
            }
            let vx = particle.velocity.dx + h * gx
            let vy = particle.velocity.dy + h * gy
            let rx = particle.position.x + h * vx
            let ry = particle.position.y + h * vy

            print("g = ", Int(gx), Int(gy), " v = ", Int(vx), Int(vy), " r = ", Int(rx), Int(ry))
            particle.velocity = CGVector(dx: vx, dy: vy)
            particle.position = CGPoint(x: rx, y: ry)
        }
        
    }

}
