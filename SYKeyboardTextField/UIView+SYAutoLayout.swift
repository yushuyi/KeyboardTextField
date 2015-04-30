//
//  UIView+SYAutoLayout.swift
//  DoudouApp
//
//  Created by yushuyi on 14/12/11.
//  Copyright (c) 2014年 DoudouApp. All rights reserved.
//

import Foundation
import UIKit

public enum SYLayoutAlignCenter : Int {
    case X = 0
    case Y
    case UpDown
    case LeftRight
    case XY
}


public extension UIView {

    func constraintHeight(constant : CGFloat){
        let constraints = self.constraints()
        for var i = 0 ; i < self.constraints().count ; i++ {
            var constraint = self.constraints()[i] as! NSLayoutConstraint
            if constraint.firstAttribute == NSLayoutAttribute.Height {
               constraint.constant = constant
               break
            }
            
        }
    }
    
    func constraintCenterX(constant : CGFloat){
        let constraints = self.constraints()
        for var i = 0 ; i < self.constraints().count ; i++ {
            var constraint = self.constraints()[i] as! NSLayoutConstraint
            if constraint.firstAttribute == NSLayoutAttribute.CenterX {
                constraint.constant = constant
                break
            }
        }
    }
    
    func constraintCenterY(constant : CGFloat){
        let constraints = self.constraints()
        for var i = 0 ; i < self.constraints().count ; i++ {
            var constraint = self.constraints()[i] as! NSLayoutConstraint
            if constraint.firstAttribute == NSLayoutAttribute.CenterY {
                constraint.constant = constant
                break
            }
        }
    }
    
    
    func toBottom (offset : CGFloat = 0.0) {
        if let superView = self.superview {
           self.bottom = superView.height - offset
        }else {
            println("UIView+SYAutoLayout toBottom 没有 superview");
        }
    }
    
    func toFullyBottom() {
        self.toBottom()
        self.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleWidth
    }

    
    
    public var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame = CGRect(origin: self.frame.origin, size: newValue)
        }
    }
    
    public var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.frame = CGRect(origin: newValue, size: self.frame.size)
        }
    }
    
    public var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame;
            frame.origin.x = newValue;
            self.frame = frame
        }
    }
    
    public var right: CGFloat{
        get {
            return self.frame.origin.x + self.frame.size.width
        }
        set {
            var frame = self.frame;
            frame.origin.x = newValue - frame.size.width;
            self.frame = frame;
        }
    }
    
    public var top: CGFloat{
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame;
            frame.origin.y = newValue;
            self.frame = frame;
        }
    }
    
    public var bottom: CGFloat{
        get {
            return self.frame.origin.y + self.frame.size.height
        }
        set {
            var frame = self.frame;
            frame.origin.y = newValue - frame.size.height;
            self.frame = frame;
        }
    }
    
    public var width: CGFloat{
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame;
            frame.size.width = newValue;
            self.frame = frame;
        }
    }
    
    public var height: CGFloat{
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame;
            frame.size.height = newValue;
            self.frame = frame;
        }
    }
    
    func alignCenter (alignCenter : SYLayoutAlignCenter) {
        
        assert(self.superview != nil, "SYAutoLayoutTips:this view not have supview")

        if let superview = self.superview {
            
            if (alignCenter == SYLayoutAlignCenter.Y || alignCenter == SYLayoutAlignCenter.UpDown) {
                self.center = CGPointMake(self.center.x, superview.frame.height/2)
            }
            else if (alignCenter == SYLayoutAlignCenter.X || alignCenter == SYLayoutAlignCenter.LeftRight) {
                self.center = CGPointMake(superview.width/2, self.center.y)
            }
            else if (alignCenter == SYLayoutAlignCenter.XY) {
                self.center = CGPointMake(superview.width/2, superview.height/2)
            }
        }
        
    }
}
