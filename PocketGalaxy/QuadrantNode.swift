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
    
    var mass:CGFloat
    var centerOfMass:CGPoint?
    var isLeaf = false
    
    init(topRight: CGPoint, bottomLeft: CGPoint) {
        quadTopRight = topRight
        quadBottomLeft = bottomLeft
        mass = 0
        particleCount = 0
    }
    
    func insert(particle: Particle) {
        
        let quadrant = getQuadrant(particle)
        let subQuadrantTopRight = getSubQuadrantTopRight(particle)
        let subQudrantBottomLeft = getSubQuadrantBottomLeft(particle)
        
        if subquadrants[quadrant] == nil {
            
            subquadrants[quadrant] = QuadrantNode(topRight: subQuadrantTopRight, bottomLeft: subQudrantBottomLeft)
            subquadrants[quadrant]!.particle = particle
            subquadrants[quadrant]!.isLeaf = true
            isLeaf = false

        } else if subquadrants[quadrant] != nil && subquadrants[quadrant]!.isLeaf { // quadrant has exactly 1 child
            
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
    
    func getSubSubQuadrantTopRight(particle: Particle) -> CGPoint {
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
    
    func getSubSubQuadrantBottomLeft(particle: Particle) -> CGPoint {
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
        
    }
    
    func getForceOnParticle(targetParticle:Particle) {
        
    }
    
}
