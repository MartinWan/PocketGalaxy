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

    var children = Dictionary<Quadrant, QuadrantNode>()
    var particles = Array<Particle>()
    
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
        let treeDepth = quadTopRight.y - quadBottomLeft.y
        
        if treeDepth <= MIN_QUADRANT_HEIGHT { // reached max tree depth
            
            particles.append(particle)
            mass += particle.mass
            
        } else if children[quadrant] == nil {
            
            let subQuadrantTopRight = getSubQuadrantTopRight(particle)
            let subQudrantBottomLeft = getSubQuadrantBottomLeft(particle)
            
            children[quadrant] = QuadrantNode(topRight: subQuadrantTopRight, bottomLeft: subQudrantBottomLeft)
            children[quadrant]!.particles.append(particle)
            children[quadrant]!.mass = particle.mass
            children[quadrant]!.isLeaf = true
            isLeaf = false

        } else if children[quadrant] != nil && children[quadrant]!.isLeaf {
            
            for existingParticle in children[quadrant]!.particles {  // recursively insert existing particles in leaf into the sub quadrant
                 children[quadrant]!.insert(existingParticle)
            }
            children[quadrant]!.insert(particle)
            
            // remove particle if is no longer a leaf node
            if (children[quadrant]!.isLeaf == false) {
                children[quadrant]!.particles.removeAll()
            }
            
            children[quadrant]!.isLeaf = false
            children[quadrant]!.mass += particle.mass
            
        } else { // more than 1 children already
            
            children[quadrant]!.insert(particle)
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
    
        mass = 0 // TODO: necessary to reset mass?
        centerOfMass = CGPoint(x: 0, y: 0)
        
        if isLeaf {
            
            for particle in particles {
                mass += particle.mass
                centerOfMass!.x += particle.position.x * particle.mass
                centerOfMass!.y += particle.position.y * particle.mass
            }
            
            centerOfMass!.x /= mass
            centerOfMass!.y /= mass
            
        } else {
            
            var cm_x = CGFloat(0.0)
            var cm_y = CGFloat(0.0)
            
            for ( _ , quadNode ) in children {
                quadNode.computeMassDistribution()
                mass += quadNode.mass
                cm_x += quadNode.centerOfMass!.x
                cm_y += quadNode.centerOfMass!.y
            }
            centerOfMass = CGPoint(x: cm_x / mass, y: cm_y / mass)
        }
    }
    
    func getFieldOnParticle(targetParticle: Particle) -> CGVector {
        
        var field = CGVector(dx: 0, dy: 0)
        
        if isLeaf {
            
            for particle in particles {
                
                let Rx = particle.position.x - targetParticle.position.x
                let Ry = particle.position.y - targetParticle.position.y
                let R = sqrt( Rx * Rx + Ry * Ry )
                
                field.dx += (particle.mass * Rx) / (R * R * R)
                field.dy += (particle.mass * Ry) / (R * R * R)
            }
        
            return field
            
        } else {
            
            let Rx = centerOfMass!.x - targetParticle.position.x
            let Ry = centerOfMass!.y - targetParticle.position.y
            let R = sqrt(Rx * Rx + Ry * Ry)
            let d = quadTopRight.y - quadBottomLeft.y
            
            let theta = CGFloat(1.0)
            
            if (d / R < theta) {
                
                field.dx = (targetParticle.mass * Rx) / (R * R * R)
                field.dy = (targetParticle.mass * Ry) / (R * R * R)

                return field
                
            } else {
                
                for ( _ , quadNode ) in children {
                    
                    let subquadrantfield = quadNode.getFieldOnParticle(targetParticle)
                    field.dx += subquadrantfield.dx
                    field.dy += subquadrantfield.dy
                }
                
                return field
            }
        }
 
    }
    
}
