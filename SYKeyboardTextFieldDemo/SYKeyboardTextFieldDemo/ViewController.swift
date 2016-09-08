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
        keyboardTextField = SYKeyboardTextField(point: CGPoint(x: 0, y: 0), width: self.view.bounds.size.width)
        keyboardTextField.delegate = self
        keyboardTextField.isLeftButtonHidden = false
        keyboardTextField.isRightButtonHidden = false
        keyboardTextField.autoresizingMask = [UIViewAutoresizing.flexibleWidth , UIViewAutoresizing.flexibleTopMargin]
        self.view.addSubview(keyboardTextField)
        keyboardTextField.toFullyBottom()
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

