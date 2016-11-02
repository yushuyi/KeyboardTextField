//
//  ViewController.swift
//  SYKeyboardTextFieldDemo
//
//  Created by yushuyi on 15/1/29.
//  Copyright (c) 2015年 yushuyi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var keyboardTextField : SYKeyboardTextField!
    
    
    override func loadView() {
        super.loadView()
        keyboardTextField = DNKeyboardTextField(point: CGPoint(x: 0, y: 0), width: self.view.bounds.size.width)
        keyboardTextField.delegate = self
        keyboardTextField.isLeftButtonHidden = true
        keyboardTextField.isRightButtonHidden = false
        keyboardTextField.autoresizingMask = [UIViewAutoresizing.flexibleWidth , UIViewAutoresizing.flexibleTopMargin]
        self.view.addSubview(keyboardTextField)
        keyboardTextField.toFullyBottom()
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        view.backgroundColor = UIColor.red
        keyboardTextField.addAttachmentView(view)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: SYKeyboardTextFieldDelegate
extension ViewController : SYKeyboardTextFieldDelegate {
    func keyboardTextFieldPressReturnButton(_ keyboardTextField: SYKeyboardTextField) {
        UIAlertView(title: "", message: "Action", delegate: nil, cancelButtonTitle: "OK").show()
    }
}


class DNKeyboardTextField : SYKeyboardTextField {

    override init(frame : CGRect) {
        super.init(frame : frame)
        self.clearTestColor()
        
        //Right Button
        self.rightButton.showsTouchWhenHighlighted = true
        self.rightButton.backgroundColor = UIColor(rgb: (252,49,89))
        self.rightButton.clipsToBounds = true
        self.rightButton.layer.cornerRadius = 18
        self.rightButton.setTitle("^0^", for: .normal)
        self.rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        //TextView
        self.textViewBackground.layer.borderColor = UIColor(rgb: (191,191,191)).cgColor
        self.textViewBackground.backgroundColor = UIColor.white
        self.textViewBackground.layer.cornerRadius = 18
        self.textViewBackground.layer.masksToBounds = true
        self.keyboardView.backgroundColor = UIColor(rgb: (238,238,238))
        self.placeholderLabel.textAlignment = .center
        self.placeholderLabel.text = "^_^"
        self.placeholderLabel.textColor = UIColor(rgb: (153,153,153))
        
        self.leftRightDistance = 15.0
        self.middleDistance = 5.0
        self.buttonMinWidth = 60
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension UIView {
    func toFullyBottom() {
        self.bottom = superview!.bounds.size.height
        self.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleWidth]
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
}

extension UIColor {
    
    convenience init(rgb: (r: CGFloat, g: CGFloat, b: CGFloat)) {
        self.init(red: rgb.r/255, green: rgb.g/255, blue: rgb.b/255, alpha: 1)
    }
    convenience init(rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)) {
        self.init(red: rgba.r/255, green: rgba.g/255, blue: rgba.b/255, alpha: rgba.a)
    }
}

