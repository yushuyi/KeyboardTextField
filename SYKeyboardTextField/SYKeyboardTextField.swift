//
//  SYKeyboardTextField.swift
//  DoudouApp
//
//  Created by yushuyi on 15/1/17.
//  Copyright (c) 2015年 DoudouApp. All rights reserved.
//

import UIKit


@objc protocol SYKeyboardTextFieldDelegate : NSObjectProtocol {

    //    /**
    //    *  键盘被主动要求取消使用时触发
    //    */
    //    - (void)keyboardTextFieldDidCancel:(SYKeyboardTextField *)aSelf;
    //didUpdateWholeHeight:(CGFloat)wholeHeight;
    //    /**
    //    *  输入了非法字符串
    //    *
    //    *  @param aSelf  self
    //    *  @param string 本次输入的非法字符串
    //    */
    //    - (void)keyboardTextField:(SYKeyboardTextField *)aSelf didInputUnsupportedString:(NSString *)string;
    
    
    /**
    点击左边按钮的委托
    */
    optional func keyboardTextFieldPressLeftButton(keyboardTextField :SYKeyboardTextField)
   
    /**
    点击右边按钮的委托
    */
    optional func keyboardTextFieldPressRightButton(keyboardTextField :SYKeyboardTextField)

    /**
    点击键盘上面的回车按钮响应委托
    */
    optional func keyboardTextFieldPressReturnButton(keyboardTextField :SYKeyboardTextField)

    /**
    键盘将要隐藏时响应的委托
    */
    optional func keyboardTextFieldWillHide(keyboardTextField :SYKeyboardTextField)

    /**
    键盘已经隐藏时响应的委托
    */
    optional func keyboardTextFieldDidHide(keyboardTextField :SYKeyboardTextField)

    /**
    键盘将要显示时响应的委托
    */
    optional func keyboardTextFieldWillShow(keyboardTextField :SYKeyboardTextField)

    /**
    键盘已经显示时响应的委托
    */
    optional func keyboardTextFieldDidShow(keyboardTextField :SYKeyboardTextField)
    
    /**
    键盘文本内容被改变时触发
    :param: text              本次写入的值
    */
    optional func keyboardTextField(keyboardTextField :SYKeyboardTextField , didChangeText text:String)

}


private let keyboardViewDefaultHeight : CGFloat = 48.0
private let textViewDefaultHeight : CGFloat = 36.0




class SYKeyboardTextField: UIView {
    
    private var hideing = false
    var sending = false
    var editing : Bool
    {
        return textView.isFirstResponder()
    }
    var leftButtonHidden : Bool = true {
        didSet
        {
            leftButton.hidden = leftButtonHidden
            self.setNeedsLayout()
        }
    }
    var rightButtonHidden : Bool = true {
        didSet
        {
            rightButton.hidden = rightButtonHidden
            self.setNeedsLayout()
        }
    }
    
    var text : String {
        return textView.text
    }
    
    var maxNumberOfWords : Int = 140
    var minNumberOfWords : Int = 0
    var maxNumberOfLines : Int = 4
    
    
    
    lazy var keyboardView = UIView()
    lazy var textView = UITextView()
    lazy var placeholderLabel = UILabel()
    lazy var textViewBackground = UIImageView()
    lazy var leftButton = UIButton()
    lazy var rightButton = UIButton()
    
    
    private var lastKeyboardFrame : CGRect = CGRectZero
    
    weak var delegate : SYKeyboardTextFieldDelegate?
    
    //便利初始化方法 通过关键字 convenience 然后 再通过 self.xxx 指向 指定构造函数
    convenience init(point : CGPoint) {
        
        self.init(frame: CGRectMake(point.x, point.y, UIScreen.mainScreen().bounds.width, keyboardViewDefaultHeight))
        self.backgroundColor = UIColor.redColor()
        
        keyboardView.frame = self.bounds
        keyboardView.backgroundColor = UIColor.yellowColor()
        keyboardView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        self.addSubview(keyboardView)
        
        keyboardView.addSubview(textViewBackground)
        
        textView.font = UIFont.systemFontOfSize(15.0);
//        textView.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -1, 0, 1);//滚动指示器 皮条
        textView.textContainerInset = UIEdgeInsetsMake(8.0, 3.0, 8.0, 0.0);
        
        textView.keyboardType = UIKeyboardType.Default;
        textView.returnKeyType = UIReturnKeyType.Done;
        textView.enablesReturnKeyAutomatically = true;
 
        textView.delegate = self
        textView.textColor = UIColor(white: 0.200, alpha: 1.000)
        textView.backgroundColor = UIColor.greenColor()
        textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        keyboardView.addSubview(textView)
        
        placeholderLabel.numberOfLines = 1
        placeholderLabel.backgroundColor = UIColor.clearColor()
        placeholderLabel.textColor = UIColor.lightGrayColor()
        placeholderLabel.font = textView.font;
        placeholderLabel.hidden = true
        placeholderLabel.text = "placeholder"
        textView.addSubview(placeholderLabel)
        
        
        leftButton.backgroundColor = UIColor.redColor()
        leftButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        leftButton.setTitle("Left", forState: UIControlState.Normal)
        leftButton.addTarget(self, action: Selector("leftButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        keyboardView.addSubview(leftButton)
        
        rightButton.backgroundColor = UIColor.redColor()
        rightButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        rightButton.setTitle("Right", forState: UIControlState.Normal)
        rightButton.addTarget(self, action: Selector("rightButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        keyboardView.addSubview(rightButton)
        
        

        self.registeringKeyboardNotification()
        
    }

    
    
    func show () {
        self.textView.becomeFirstResponder()
    }
    
    func hide () {
        self.textView.resignFirstResponder()
        self.endEditing(true)
    }
    func clearTestColor() {
        self.backgroundColor = UIColor.clearColor()
        leftButton.backgroundColor = UIColor.clearColor()
        rightButton.backgroundColor = UIColor.clearColor()
        textView.backgroundColor = UIColor.clearColor()
        textViewBackground.backgroundColor = UIColor.clearColor()
    }
    
    @objc private func leftButtonAction(button : UIButton) {
        self.delegate?.keyboardTextFieldPressLeftButton?(self)
    }
    
    @objc private func rightButtonAction(button : UIButton) {
        self.delegate?.keyboardTextFieldPressRightButton?(self)
    }
    
 
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var distance : CGFloat = 8.0
        
        var maxWidth : CGFloat = 65.0
        var minWidth : CGFloat = 45.0

        if leftButtonHidden == false {
            var leftButtonWidth : CGFloat = 0.0
            self.leftButton.sizeToFit()
            if (minWidth <= leftButton.width) {
                leftButtonWidth = leftButton.width + 10
            }else {
                leftButtonWidth = minWidth
            }
            if (leftButton.width > maxWidth)
            {
                leftButtonWidth = maxWidth
            }
            leftButton.frame = CGRectMake(distance, 0, leftButtonWidth, textViewDefaultHeight);
            leftButton.toBottom(offset: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0)
        }
        
        if rightButtonHidden == false {
            var rightButtonWidth : CGFloat = 0.0
            self.rightButton.sizeToFit()
            if (minWidth <= rightButton.width) {
                rightButtonWidth = rightButton.width + 10;
            }else {
                rightButtonWidth = minWidth
            }
            if (rightButton.width > maxWidth)
            {
                rightButtonWidth = maxWidth;
            }
            rightButton.frame = CGRectMake(keyboardView.width - distance - rightButtonWidth, 0, rightButtonWidth, textViewDefaultHeight);
            rightButton.toBottom(offset: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0)
        }
        
        textView.frame =
            CGRectMake(
                (leftButtonHidden == false ? leftButton.right:0) + distance,
                (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0 + 0.5,
                keyboardView.width
                    - (leftButtonHidden == false ? leftButton.width + distance:0)
                    - (rightButtonHidden == false ? rightButton.width + distance:0)
                    - distance * 2,
                textViewCurrentHeightForLines(self.textView.numberOfLines())
        )
        textViewBackground.frame = textView.frame;
    }
 
    deinit {
        println("\(NSStringFromClass(self.classForCoder)) has release!")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}


//MARK: TextViewHeight

extension SYKeyboardTextField {

    private func textViewCurrentHeightForLines(numberOfLines : Int) -> CGFloat
    {
        var height = textViewDefaultHeight - self.textView.font.lineHeight
        var lineTotalHeight = self.textView.font.lineHeight * CGFloat(numberOfLines)
        height += CGFloat(roundf(Float(lineTotalHeight)))
        return height;
    }
    
    private func appropriateInputbarHeight() -> CGFloat
    {
        var height : CGFloat = 0.0;
        
        if self.textView.numberOfLines() == 1 {
            height = textViewDefaultHeight;
        }else if self.textView.numberOfLines() < self.maxNumberOfLines {
            height = self.textViewCurrentHeightForLines(self.textView.numberOfLines())
        }
        else {
            height = self.textViewCurrentHeightForLines(self.maxNumberOfLines)
        }
        
        height += keyboardViewDefaultHeight - textViewDefaultHeight;
        
        if (height < keyboardViewDefaultHeight) {
            height = keyboardViewDefaultHeight;
        }
        return CGFloat(roundf(Float(height)));
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if object.isEqual(self.textView) && keyPath == "contentSize" {
            var newValue = change[NSKeyValueChangeNewKey]?.CGSizeValue()
//            println("\(newValue)---\(self.appropriateInputbarHeight())")
            var newKeyboardHeight = self.appropriateInputbarHeight()
            
            if newKeyboardHeight != keyboardView.height && self.superview != nil {
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    var lastKeyboardFrameHeight = (self.lastKeyboardFrame.origin.y == 0.0 ? self.superview!.height : self.lastKeyboardFrame.origin.y)
                    self.frame = CGRectMake(self.frame.origin.x,  lastKeyboardFrameHeight - newKeyboardHeight, self.frame.size.width, newKeyboardHeight)
                    }, completion:nil
                )
            }
        }
    }
}

//MARK: Keyboard Notification 

extension SYKeyboardTextField {
    
    var keyboardAnimationOptions : UIViewAnimationOptions {
        return  UIViewAnimationOptions((7 as UInt) << 16)
    }
    var keyboardAnimationDuration : NSTimeInterval {
        return  NSTimeInterval(0.25)
    }
    
    private func registeringKeyboardNotification() {
        //  Registering for keyboard notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:",name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:",name: UIKeyboardDidHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:",name:UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidChangeFrame:",name:UIKeyboardDidChangeFrameNotification, object: nil)
        
        //  Registering for orientation changes notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willChangeStatusBarOrientation:",name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)
    
    }
    
    @objc private func keyboardWillShow(notification : NSNotification) {
        if textView.isFirstResponder() {
            self.delegate?.keyboardTextFieldWillShow?(self)
        }
    }
    @objc private func keyboardDidShow(notification : NSNotification) {
        if textView.isFirstResponder() {
            self.delegate?.keyboardTextFieldDidShow?(self)
        }
    }
    @objc private func keyboardWillHide(notification : NSNotification) {
        if textView.isFirstResponder() {
            hideing = true
            self.delegate?.keyboardTextFieldWillHide?(self)
        }
    }
    @objc private func keyboardDidHide(notification : NSNotification) {
        if hideing {
            hideing = false
            self.delegate?.keyboardTextFieldDidHide?(self)
        }
    }
    @objc private func keyboardWillChangeFrame(notification : NSNotification) {
        if self.window == nil { return }
        if !self.window!.keyWindow { return }
        
        if textView.isFirstResponder() {
            var userInfo = notification.userInfo as [String : AnyObject]
            var keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue
            var keyboardFrame = keyboardFrameValue.CGRectValue()
            lastKeyboardFrame = self.superview!.convertRect(keyboardFrame, fromView: UIApplication.sharedApplication().keyWindow)
            //            println(keyboardFrame)
            
            //只有iOS 7 需要 这样获取 options   iOS 8 已经默认包含动画
            var options = UIViewAnimationOptions((userInfo[UIKeyboardAnimationCurveUserInfoKey] as UInt) << 16)
            
            UIView.animateWithDuration(keyboardAnimationDuration, delay: 0.0, options: keyboardAnimationOptions, animations: { () -> Void in
                self.top = self.lastKeyboardFrame.origin.y - self.keyboardView.height
                }, completion: nil)
            
        }
    }
    
    
    @objc private func keyboardDidChangeFrame(notification : NSNotification) {}
    
    
    @objc private func willChangeStatusBarOrientation(notification : NSNotification) {
        
    }

}


//MARK: TapButtonAction
extension SYKeyboardTextField {

    private var tapButtonTag : Int { return 12345 }
    private var tapButton : UIButton { return self.superview!.viewWithTag(tapButtonTag) as UIButton }
    
    @objc private func tapAction(button : UIButton) {
        self.hide()
    }
    
    private func setTapButtonHidden(hidden : Bool) {
        self.tapButton.hidden = hidden
        if hidden == false {
            if let tapButtonSuperView = self.tapButton.superview {
                tapButtonSuperView.insertSubview(self.tapButton, belowSubview: self)
            }
        }
    }
    
    override func didMoveToSuperview() {
        if let superview = self.superview {
            var tapButton = UIButton(frame: superview.bounds)
            tapButton.addTarget(self, action: "tapAction:", forControlEvents: UIControlEvents.TouchUpInside)
            tapButton.tag = tapButtonTag
            tapButton.hidden = true
            tapButton.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
            tapButton.backgroundColor = UIColor.clearColor()
            superview.insertSubview(tapButton, atIndex: 0);
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if ((self.superview != nil) && newSuperview == nil) {
            self.superview?.viewWithTag(tapButtonTag)?.removeFromSuperview()
            textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        }
    }
}


//MARK: UITextViewDelegate
extension SYKeyboardTextField : UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        self.delegate?.keyboardTextField?(self, didChangeText: self.textView.text)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        self.setTapButtonHidden(false)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.setTapButtonHidden(true)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }

    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if sending { return false }
        if text == "\n" {
            if sending == false {
                self.delegate?.keyboardTextFieldPressReturnButton?(self)
            }
            return false
        }
        return true
    }
}

//MARK: UITextView extension
extension UITextView {

    func numberOfLines() -> Int
    {
        var line = self.contentSize.height / self.font.lineHeight
        if line < 1.0 { return 1 }
        return abs(Int(line))
    }

}

