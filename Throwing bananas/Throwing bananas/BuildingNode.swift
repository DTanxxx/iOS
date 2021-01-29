//
//  BuildingNode.swift
//  Throwing bananas
//
//  Created by David Tan on 21/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import SpriteKit
import UIKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class BuildingNode: SKSpriteNode {
    
    // no custom initialiser so subclass will use parent initialiser
    
    var currentImage: UIImage!
    
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        // 1. Create a new Core Graphics context the size of our building.
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            // 2. Fill it with a rectangle that's one of three colors.
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            let color: UIColor
            
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            // 3. Draw windows all over the building in one of two colors: there's either a light on (yellow) or not (gray).
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            // stride() lets you loop from one number to another with a specific interval
            // stride(from:to:by:) excludes 'to' parameter; stride(from:through:by:) includes 'through' parameter
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
            
            // 4. Pull out the result as a UIImage and return it for use elsewhere.
        }
        
        return img
    }
    
    func hit(at point: CGPoint) {
        
        // MARK: - the image renderer context has its origin at top left corner
        
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))  // the converted coordinates represent the same point in a renderer context's coordinate system
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            currentImage.draw(at: .zero)
            
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            ctx.cgContext.setBlendMode(.clear)  // .clear means 'delete whatever is there already'
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        
        configurePhysics()
    }
    
}
