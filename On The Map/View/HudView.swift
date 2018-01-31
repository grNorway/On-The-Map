//
//  HUDView.swift
//  On The Map
//
//  Created by scythe on 12/15/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//


// A Heads - Up - Display
// This is a UIView that shows a image and rotates the image while there is a loading process


import UIKit

class HudView : UIView {
 
    /* It calls it self and adds to the current View the HUDVIEW  and starts the animation */
    class func hud(inView view : UIView , animated : Bool) -> HudView{
        
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        hudView.show(animated: animated)
        
        return hudView
    }
    
    /* Draws the image at the center of the view */
    override func draw(_ rect: CGRect) {

        let boxWidth:CGFloat = 45
        let boxHeight:CGFloat = 45
        
        let boxRect = CGRect(x: (bounds.size.width - boxWidth) / 2, y: (bounds.size.height - boxHeight) / 2, width: boxWidth, height: boxHeight)
        
        let circleRect = UIBezierPath(roundedRect: boxRect, cornerRadius: boxWidth/2)
        UIColor(white: 0.2, alpha: 0.8).setFill()
        circleRect.fill()
        
        
        if let image = UIImage(named: "loading"){
            
            image.draw(at: CGPoint(x: center.x - image.size.width / 2, y: center.y - image.size.height / 2))
        }
        
    }
    
    
    /* It animates the hudView and after 0.3 sec it rotate the hudView */
    private func show(animated : Bool){
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 3.3, y: 3.3)
       
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: { (success) in
                if success {
                    self.rotateAnimation()
                }
            })
                
                
        }
    }
    
    /* Rotation Animation with repeatCount to infinitive */
    private func rotateAnimation(){
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.duration = 2.0
        rotateAnimation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotateAnimation, forKey: nil)
        
    }
    
}















