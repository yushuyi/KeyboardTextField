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
        keyboardTextField = SYKeyboardTextField(point: CGPointMake(0, 0), width: self.view.width)
        keyboardTextField.delegate = self
        keyboardTextField.leftButtonHidden = false
        keyboardTextField.rightButtonHidden = false
        keyboardTextField.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , UIViewAutoresizing.FlexibleTopMargin]
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
    func keyboardTextFieldPressReturnButton(keyboardTextField: SYKeyboardTextField) {
        UIAlertView(title: "", message: "Action", delegate: nil, cancelButtonTitle: "OK").show()
    }
}