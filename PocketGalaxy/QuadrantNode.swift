//
//  QuadrantNode.swift
//  PocketGalaxy
//
//  Created by Martin  on 2016-05-23.
//  Copyright © 2016 Martin . All rights reserved.
//

import SpriteKit

enum Quadrant:Int {
    case NW = 0
    case NE = 1
    case SW = 2
    case SE = 3
}

class QuadrantNode {

    var subquadrants = Dictionary<Quadrant, QuadrantNode>()
    var particle:Particle?
    
    var quadTopRight:CGPoint
    var quadBottomLeft:CGPoint
    var isLeaf:Bool
    
    var mass:CGFloat
    var centerOfMass:CGPoint?

    init(topRight: CGPoint, bottomLeft: CGPoint) {
        quadTopRight = topRight
        quadBottomLeft = bottomLeft
        mass = 0
        isLeaf = false
    }
    
    func insert(particle: Particle) {
        
        let quadrant = getQuadrant(particle)
        
        if subquadrants[quadrant] == nil {
            
            let subQuadrantTopRight = getSubQuadrantTopRight(particle)
            let subQudrantBottomLeft = getSubQuadrantBottomLeft(particle)
            
            subquadrants[quadrant] = QuadrantNode(topRight: subQuadrantTopRight, bottomLeft: subQudrantBottomLeft)
            subquadrants[quadrant]!.particle = particle
            subquadrants[quadrant]!.mass = particle.mass
            subquadrants[quadrant]!.isLeaf = true
            isLeaf = false

        } else if subquadrants[quadrant] != nil && subquadrants[quadrant]!.isLeaf {
            
            let existingParticle = subquadrants[quadrant]!.particle! // must have particle since is leaf node
            
            // remove particle from the leaf node
            subquadrants[quadrant]!.particle = nil
            subquadrants[quadrant]!.isLeaf = false
            
            // recursively insert existing particle and new particle
            subquadrants[quadrant]!.insert(existingParticle)
            subquadrants[quadrant]!.insert(particle)
            
        } else { // more than 1 subquadrants already
            subquadrants[quadrant]!.insert(particle)
        }
    }
    
    func getQuadrant(particle: Particle) -> Quadrant {
        
        let width = quadTopRight.x - quadBottomLeft.x
        let height = quadTopRight.y - quadBottomLeft.y
        
        let quadMidX = quadBottomLeft.x + width / 2
        let quadMidY = quadBottomLeft.y + height / 2
        
        if (particle.position.x < quadMidX && particle.position.y < quadMidY) {
            return Quadrant.SW
        } else if (particle.position.x < quadMidX && particle.position.y > quadMidY) {
            return Quadrant.NW
        } else if (particle.position.x > quadMidX && particle.position.y < quadMidY) {
            return Quadrant.SE
        } else {
            return Quadrant.NE
        }
    }
    
    func getSubQuadrantTopRight(particle: Particle) -> CGPoint {
        let width = quadTopRight.x - quadBottomLeft.x
        let height = quadTopRight.y - quadBottomLeft.y
        
        let quadMidX = quadBottomLeft.x + width / 2
        let quadMidY = quadBottomLeft.y + height / 2
        
        if (particle.position.x < quadMidX && particle.position.y < quadMidY) {
            return CGPoint(x: quadMidX, y: quadMidY)
        } else if (particle.position.x < quadMidX && particle.position.y > quadMidY) {
            return CGPoint(x: quadMidX, y: quadTopRight.y)
        } else if (particle.position.x > quadMidX && particle.position.y < quadMidY) {
            return CGPoint(x: quadTopRight.x, y: quadMidY)
        } else {
            return quadTopRight
        }
    }
    
    func getSubQuadrantBottomLeft(particle: Particle) -> CGPoint {
        let width = quadTopRight.x - quadBottomLeft.x
        let height = quadTopRight.y - quadBottomLeft.y
        
        let quadMidX = quadBottomLeft.x + width / 2
        let quadMidY = quadBottomLeft.y + height / 2
        
        if (particle.position.x < quadMidX && particle.position.y < quadMidY) {
            return quadBottomLeft
        } else if (particle.position.x < quadMidX && particle.position.y > quadMidY) {
            return CGPoint(x: quadBottomLeft.x, y: quadMidY)
        } else if (particle.position.x > quadMidX && particle.position.y < quadMidY) {
           return CGPoint(x: quadMidX, y: quadBottomLeft.y)
        } else {
            return CGPoint(x: quadMidX, y: quadMidY)
        }
    }
    
    func computeMassDistribution() {
    
        if isLeaf {
            centerOfMass = particle!.position
            mass = particle!.mass
        } else {
            
            var cm_x = CGFloat(0.0)
            var cm_y = CGFloat(0.0)
            
            for ( _ , quadNode ) in subquadrants {
                quadNode.computeMassDistribution()
                mass += quadNode.mass
                cm_x += quadNode.centerOfMass!.x
                cm_y += quadNode.centerOfMass!.y
            }
            centerOfMass = CGPoint(x: cm_x / mass, y: cm_y / mass)
        }
    }
    
    func getForceOnParticle(targetParticle:Particle) -> CGVector {
        
        var force = CGVector(dx: 0, dy: 0)
        
        if isLeaf && particle != nil { // TODO: shouldn't isLeaf always mean particle isn't nil?
            
            let Rx = particle!.position.x - targetParticle.position.x
            let Ry = particle!.position.y - targetParticle.position.y
            let R = sqrt( Rx * Rx + Ry * Ry )
            
            force.dx = (particle!.mass * targetParticle.mass) * Rx / (R * R * R)
            force.dy = (particle!.mass * targetParticle.mass) * Ry / (R * R * R)
            
            return force
            
        } else {
            
            let Rx = centerOfMass!.x - targetParticle.position.x
            let Ry = centerOfMass!.y - targetParticle.position.y
            let R = sqrt(Rx * Rx + Ry * Ry)
            let d = quadTopRight.y - quadBottomLeft.y
            
            let theta = CGFloat(1.0)
            
            if (d / R < theta) {
                
                force.dx = (targetParticle.mass * self.mass) * Rx / (R * R * R)
                force.dy = (targetParticle.mass * self.mass) * Ry / (R * R * R)

                return force
            } else {
                
                for ( _ , quadNode ) in subquadrants {
                    
                    let subquadrantForce = quadNode.getForceOnParticle(targetParticle)
                    force.dx += subquadrantForce.dx
                    force.dy += subquadrantForce.dy
                }
                
                return force
                
            }
        }
        
    }
    
}
