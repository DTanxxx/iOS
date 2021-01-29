//
//  ViewController.swift
//  Core Graphics
//
//  Created by David Tan on 17/01/20.
//  Copyright © 2020 LearnAppMaking. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //drawRectangle()
        drawRectangle()
    }


    @IBAction func redrawTapped(_ sender: UIButton) {
        currentDrawType += 1
        
        if currentDrawType > 7 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()
        case 6:
            drawStar()
        case 7:
            spellTwin()
        default:
            break
        }
    }
    
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        // the actual rendering is done by the image() method
        let img = renderer.image { ctx in
            // the ctx variable stores the UIGraphicsImageRendererContext object, which is a canvas upon which we can draw
            // the context object also stores information about how we want to draw
            // note: the UIGraphicsImageRendererContext is actually a wrapper class for another data type called CGContext. This data type stores the majority of the drawing code.
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)  // set the line color
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rectangle)  // adds a rectangle path to be drawn
            ctx.cgContext.drawPath(using: .fillStroke)  // draws the path
        }
        
        imageView.image = img
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = img
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                        // the fill() method skips the add path / draw path work and just fills the rectangle given as its parameter using whatever the current fill color is
                    }
                }
            }
        }
        
        imageView.image = img
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            for _ in 0 ..< rotations {
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: .pi / 2)
                
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
    
    func drawImagesAndText() {
        // 1. Create a renderer at the correct size.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            // 2. Define a paragraph style that aligns text to the center.
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // 3. Create an attributes dictionary containing that paragraph style, and also a font.
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle,
            ]
            
            // 4. Wrap that attributes dictionary and a string into an instance of NSAttributedString.
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            
            // 5. Load an image from the project and draw it to the context.
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        // 6. Update the image view with the finished result.
        imageView.image = img
    }
    
    func drawStar() {
        let x = [15, 65, 25, 40, 0]
        var neg = [Int]()
        for i in x { neg.append(-i) }
        neg.removeLast()
        
        var y =  [-52, -52, -23, 25, -4]
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            ctx.cgContext.move(to: CGPoint(x: 0, y: -100))
            
            // right half of star
            for (index, coordinate) in x.enumerated() {
                ctx.cgContext.addLine(to: CGPoint(x: coordinate, y: y[index]))
            }
            
            y.removeLast()
            
            // left half of star
            for (index, coordinate) in neg.reversed().enumerated() {
                ctx.cgContext.addLine(to: CGPoint(x: coordinate, y: y.reversed()[index]))
            }
            
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: -100))
            
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.blue.cgColor)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = img
    }
    
    func spellTwin() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        let img = renderer.image { (ctx) in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            // letter 'T'
            ctx.cgContext.move(to: CGPoint(x: -150, y: -50))
            ctx.cgContext.addLine(to: CGPoint(x: -100, y: -50))
            ctx.cgContext.move(to: CGPoint(x: -125, y: -50))
            ctx.cgContext.addLine(to: CGPoint(x: -125, y: 20))
            
            // letter 'W'
            ctx.cgContext.move(to: CGPoint(x: -85, y: -50))
            ctx.cgContext.addLine(to: CGPoint(x: -65, y: 20))
            ctx.cgContext.addLine(to: CGPoint(x: -50, y: -15))
            ctx.cgContext.addLine(to: CGPoint(x: -35, y: 20))
            ctx.cgContext.addLine(to: CGPoint(x: -15, y: -50))
            
            // letter 'I'
            ctx.cgContext.move(to: CGPoint(x: 0, y: -50))
            ctx.cgContext.addLine(to: CGPoint(x: 25, y: -50))
            ctx.cgContext.move(to: CGPoint(x: 12.5, y: -50))
            ctx.cgContext.addLine(to: CGPoint(x: 12.5, y: 20))
            ctx.cgContext.move(to: CGPoint(x: 0, y: 20))
            ctx.cgContext.addLine(to: CGPoint(x: 25, y: 20))
            
            // letter 'N'
            ctx.cgContext.move(to: CGPoint(x: 40, y: 22))
            ctx.cgContext.addLine(to: CGPoint(x: 40, y: -48))
            ctx.cgContext.addLine(to: CGPoint(x: 90, y: 18))
            ctx.cgContext.addLine(to: CGPoint(x: 90, y: -52))
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(3)
            ctx.cgContext.drawPath(using: .stroke)
        }
        
        imageView.image = img
    }
    
}
// NOTE: when using Editor to set constraints, select the 'Reset to suggested constraints' under 'All views in container' not 'Selected views'
