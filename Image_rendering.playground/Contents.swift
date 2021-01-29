import UIKit

let format = UIGraphicsImageRendererFormat()
format.scale = UIScreen.main.scale  // this line is required for proper display of rendered image
format.opaque = true

let bounds = CGRect(x: 0, y: 0, width: 128, height: 128)  // image will be 128x128

let renderer = UIGraphicsImageRenderer(bounds: bounds, format: format)
let result = renderer.image { (ctx) in
    // note that the 'ctx' parameter is not a CGContext, instead it's a UIGraphicsImageRendererContext
    // if we want to get access to CGContext, we use 'ctx.cgContext' to get hold of it
    
    UIColor.red.set()  // image will be red
    ctx.fill(bounds)
    
    ctx.cgContext.saveGState()
    ctx.cgContext.translateBy(x: 64, y: 96)
    
    let rotations = 16
    let amount = Double.pi / Double(rotations)
    UIColor.white.set()
    
    for _ in 0 ..< rotations {
        ctx.cgContext.rotate(by: CGFloat(amount))
        ctx.stroke(CGRect(x: -32, y: -32, width: 64, height: 64))
        ctx.currentImage
    }
    
    ctx.cgContext.restoreGState()
    
    let ps = NSMutableParagraphStyle()
    ps.alignment = .center
    
    let attrs = [
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32),
        NSAttributedString.Key.paragraphStyle: ps
    ]
    
    let testString = NSAttributedString(string: "Testy", attributes: attrs)
    testString.draw(in: bounds)
}

result
