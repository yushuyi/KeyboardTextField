//
//  SYKeyboardTextField.swift
//  DoudouApp
//
//  Created by yushuyi on 15/1/17.
//  Copyright (c) 2015年 DoudouApp. All rights reserved.
//

import UIKit

@objc public protocol SYKeyboardTextFieldDelegate : class {

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
    - parameter text:              本次写入的值
    */
    optional func keyboardTextField(keyboardTextField :SYKeyboardTextField , didChangeText text:String)

}


private var keyboardViewDefaultHeight : CGFloat = 48.0
private let textViewDefaultHeight : CGFloat = 36.0




public class SYKeyboardTextField: UIView {
    
    private var hideing = false
    public var sending = false
    
    public var enabled: Bool = true
    {
        didSet {
            textView.editable = enabled
            leftButton.enabled = enabled
            rightButton.enabled = enabled
        }
    }
    public var editing : Bool
    {
        return textView.isFirstResponder()
    }
    public var leftButtonHidden : Bool = true {
        didSet
        {
            leftButton.hidden = leftButtonHidden
            self.setNeedsLayout()
        }
    }
    public var rightButtonHidden : Bool = true {
        didSet
        {
            rightButton.hidden = rightButtonHidden
            self.setNeedsLayout()
        }
    }
    
    public var text : String! {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            self.textViewDidChange(textView)
            self.layoutIfNeeded()
        }
    }
    
    public var maxNumberOfWords : Int = 140
    public var minNumberOfWords : Int = 0
    public var maxNumberOfLines : Int = 4
    
    
    //UI
    public lazy var keyboardView = UIView()
    public lazy var textView : SYKeyboardTextView = SYKeyboardTextView()
    public lazy var placeholderLabel = UILabel()
    public lazy var textViewBackground = UIImageView()
    public lazy var leftButton = UIButton()
    public lazy var rightButton = UIButton()
    
    
    private var lastKeyboardFrame : CGRect = CGRectZero
    
    public weak var delegate : SYKeyboardTextFieldDelegate?
    
    public override init(frame : CGRect) {
        super.init(frame : frame)
        keyboardViewDefaultHeight = frame.height
        self.backgroundColor = UIColor.redColor()
        
        keyboardView.frame = self.bounds
        keyboardView.backgroundColor = UIColor.yellowColor()
        keyboardView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.addSubview(keyboardView)
        
        keyboardView.addSubview(textViewBackground)
        
        textView.font = UIFont.systemFontOfSize(15.0);
        //        textView.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -1, 0, 1);//滚动指示器 皮条
        textView.textContainerInset = UIEdgeInsetsMake(9.0, 3.0, 7.0, 0.0);
        textView.autocorrectionType = .No
        textView.keyboardType = UIKeyboardType.Default;
        textView.returnKeyType = UIReturnKeyType.Done;
        textView.enablesReturnKeyAutomatically = true;
        
        textView.delegate = self
        textView.textColor = UIColor(white: 0.200, alpha: 1.000)
        textView.backgroundColor = UIColor.greenColor()
        textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        textView.scrollsToTop = false
        keyboardView.addSubview(textView)
        
        placeholderLabel.textAlignment = NSTextAlignment.Left
        placeholderLabel.numberOfLines = 1
        placeholderLabel.backgroundColor = UIColor.clearColor()
        placeholderLabel.textColor = UIColor.lightGrayColor()
        placeholderLabel.font = textView.font;
        placeholderLabel.hidden = false
        placeholderLabel.text = "placeholder"
        textView.addSubview(placeholderLabel)
        
        
        leftButton.backgroundColor = UIColor.redColor()
        leftButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        leftButton.setTitle("Left", forState: UIControlState.Normal)
        leftButton.addTarget(self, action: #selector(SYKeyboardTextField.leftButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        keyboardView.addSubview(leftButton)
        
        rightButton.backgroundColor = UIColor.redColor()
        rightButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        rightButton.setTitle("Right", forState: UIControlState.Normal)
        rightButton.addTarget(self, action: #selector(SYKeyboardTextField.rightButtonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        keyboardView.addSubview(rightButton)
        
        self.registeringKeyboardNotification()
        
    }
    
    //便利初始化方法 通过关键字 convenience 然后 再通过 self.xxx 指向 指定构造函数
    public convenience init(point : CGPoint,width : CGFloat) {
        self.init(frame: CGRectMake(point.x, point.y, width, keyboardViewDefaultHeight))
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func show () {
        self.textView.becomeFirstResponder()
    }
    
    public func hide () {
        self.textView.resignFirstResponder()
        self.endEditing(true)
    }
    public func clearTestColor() {
        self.backgroundColor = UIColor.clearColor()
        leftButton.backgroundColor = UIColor.clearColor()
        rightButton.backgroundColor = UIColor.clearColor()
        textView.backgroundColor = UIColor.clearColor()
        textViewBackground.backgroundColor = UIColor.clearColor()
    }
    
    func leftButtonAction(button : UIButton) {
        self.delegate?.keyboardTextFieldPressLeftButton?(self)
    }
    
    func rightButtonAction(button : UIButton) {
        self.delegate?.keyboardTextFieldPressRightButton?(self)
    }
    
  
    public var leftRightDistance : CGFloat = 8.0
    public var middleDistance : CGFloat = 8.0
    
    public var buttonMaxWidth : CGFloat = 65.0
    public var buttonMinWidth : CGFloat = 45.0
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        if leftButtonHidden == false {
            var leftButtonWidth : CGFloat = 0.0
            self.leftButton.sizeToFit()
            if (buttonMinWidth <= leftButton.width) {
                leftButtonWidth = leftButton.width + 10
            }else {
                leftButtonWidth = buttonMinWidth
            }
            if (leftButton.width > buttonMaxWidth)
            {
                leftButtonWidth = buttonMaxWidth
            }
            leftButton.frame = CGRectMake(leftRightDistance, 0, leftButtonWidth, textViewDefaultHeight);
            leftButton.toBottom(offset: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0)
        }
        
        if rightButtonHidden == false {
            var rightButtonWidth : CGFloat = 0.0
            self.rightButton.sizeToFit()
            if (buttonMinWidth <= rightButton.width) {
                rightButtonWidth = rightButton.width + 10;
            }else {
                rightButtonWidth = buttonMinWidth
            }
            if (rightButton.width > buttonMaxWidth)
            {
                rightButtonWidth = buttonMaxWidth;
            }
            rightButton.frame = CGRectMake(keyboardView.width - leftRightDistance - rightButtonWidth, 0, rightButtonWidth, textViewDefaultHeight);
            rightButton.toBottom(offset: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0)
        }
        
        textView.frame =
            CGRectMake(
                (leftButtonHidden == false ? leftButton.right + middleDistance : leftRightDistance),
                (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0 + 0.5,
                keyboardView.width
                    - (leftButtonHidden == false ? leftButton.width + middleDistance:0)
                    - (rightButtonHidden == false ? rightButton.width + middleDistance:0)
                    - leftRightDistance * 2,
                textViewCurrentHeightForLines(self.textView.numberOfLines())
        )
        textViewBackground.frame = textView.frame;
        
        if placeholderLabel.textAlignment == .Left {
            placeholderLabel.sizeToFit()
            placeholderLabel.origin = CGPointMake(8.0, (textViewDefaultHeight - placeholderLabel.height) / 2);
            
        }else if placeholderLabel.textAlignment == .Center {
           placeholderLabel.frame = placeholderLabel.superview!.bounds
        }
    }
 
    deinit {
        if SYKeyboardTextFieldDebugMode {
            print("\(NSStringFromClass(self.classForCoder)) has release!")
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}


//MARK: TextViewHeight

extension SYKeyboardTextField {

    private func textViewCurrentHeightForLines(numberOfLines : Int) -> CGFloat
    {
        var height = textViewDefaultHeight - self.textView.font!.lineHeight
        let lineTotalHeight = self.textView.font!.lineHeight * CGFloat(numberOfLines)
        height += CGFloat(roundf(Float(lineTotalHeight)))
        return CGFloat(Int(height));
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
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let object = object,let change = change else { return }
        
        if object.isEqual(self.textView) && keyPath == "contentSize" {
            if SYKeyboardTextFieldDebugMode {
                let newValue = change[NSKeyValueChangeNewKey]?.CGSizeValue()
                print("\(newValue)---\(self.appropriateInputbarHeight())")
            }
            
            let newKeyboardHeight = self.appropriateInputbarHeight()
            if newKeyboardHeight != keyboardView.height && self.superview != nil {
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    let lastKeyboardFrameHeight = (self.lastKeyboardFrame.origin.y == 0.0 ? self.superview!.height : self.lastKeyboardFrame.origin.y)
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
        return  UIViewAnimationOptions(rawValue: (7 as UInt) << 16)
    }
    var keyboardAnimationDuration : NSTimeInterval {
        return  NSTimeInterval(0.25)
    }
    
    func registeringKeyboardNotification() {
        //  Registering for keyboard notification.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SYKeyboardTextField.keyboardWillShow(_:)),name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SYKeyboardTextField.keyboardDidShow(_:)),name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SYKeyboardTextField.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SYKeyboardTextField.keyboardDidHide(_:)),name: UIKeyboardDidHideNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SYKeyboardTextField.keyboardWillChangeFrame(_:)),name:UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SYKeyboardTextField.keyboardDidChangeFrame(_:)),name:UIKeyboardDidChangeFrameNotification, object: nil)
        
        //  Registering for orientation changes notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SYKeyboardTextField.willChangeStatusBarOrientation(_:)),name: UIApplicationWillChangeStatusBarOrientationNotification, object: nil)
    
    }
    
    func keyboardWillShow(notification : NSNotification) {
        if textView.isFirstResponder() {
            self.delegate?.keyboardTextFieldWillShow?(self)
        }
    }
    func keyboardDidShow(notification : NSNotification) {
        if textView.isFirstResponder() {
            self.delegate?.keyboardTextFieldDidShow?(self)
        }
    }
    func keyboardWillHide(notification : NSNotification) {
        if textView.isFirstResponder() {
            hideing = true
            self.delegate?.keyboardTextFieldWillHide?(self)
        }
    }
    func keyboardDidHide(notification : NSNotification) {
        if hideing {
            hideing = false
            self.delegate?.keyboardTextFieldDidHide?(self)
        }
    }
    func keyboardWillChangeFrame(notification : NSNotification) {
        if self.window == nil { return }
        if !self.window!.keyWindow { return }
        
        if textView.isFirstResponder() {
            var userInfo = notification.userInfo as! [String : AnyObject]
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
            let keyboardFrame = keyboardFrameValue.CGRectValue()
            lastKeyboardFrame = self.superview!.convertRect(keyboardFrame, fromView: UIApplication.sharedApplication().keyWindow)
            if SYKeyboardTextFieldDebugMode {
                print("keyboardFrame : \(keyboardFrame)")
            }
            
            UIView.animateWithDuration(keyboardAnimationDuration, delay: 0.0, options: keyboardAnimationOptions, animations: { () -> Void in
                self.top = self.lastKeyboardFrame.origin.y - self.keyboardView.height
                }, completion: nil)
            
        }
    }
    
    func keyboardDidChangeFrame(notification : NSNotification) {}
    func willChangeStatusBarOrientation(notification : NSNotification) {}

}


//MARK: TapButtonAction
extension SYKeyboardTextField {

    private var tapButtonTag : Int { return 12345 }
    private var tapButton : UIButton { return self.superview!.viewWithTag(tapButtonTag) as! UIButton }
    func tapAction(button : UIButton) {
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
    
    override public func didMoveToSuperview() {
        if let superview = self.superview {
            let tapButton = UIButton(frame: superview.bounds)
            tapButton.addTarget(self, action: #selector(SYKeyboardTextField.tapAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            tapButton.tag = tapButtonTag
            tapButton.hidden = true
            tapButton.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            tapButton.backgroundColor = UIColor.clearColor()
            superview.insertSubview(tapButton, atIndex: 0);
        }
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        if ((self.superview != nil) && newSuperview == nil) {
            self.superview?.viewWithTag(tapButtonTag)?.removeFromSuperview()
            textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        }
    }
}


//MARK: UITextViewDelegate
extension SYKeyboardTextField : UITextViewDelegate {
    
    public func textViewDidChange(textView: UITextView) {
        
        if (textView.text.characters.isEmpty) {
            placeholderLabel.alpha = 1
        }
        else {
            placeholderLabel.alpha = 0
        }
        
        self.delegate?.keyboardTextField?(self, didChangeText: self.textView.text)
    }
    
    public func textViewDidBeginEditing(textView: UITextView) {
        self.setTapButtonHidden(false)
    }
    
    public func textViewDidEndEditing(textView: UITextView) {
        self.setTapButtonHidden(true)
    }
    
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }

    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        return true
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
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

public class SYKeyboardTextView : UITextView {
    private var hasDragging : Bool = false
    override public func layoutSubviews() {
        super.layoutSubviews()
        if self.dragging == false {
            if hasDragging {
                let delayTime = dispatch_time(DISPATCH_TIME_NOW,Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.hasDragging = false
                }
            }else {
                if selectedRange.location == text.characters.count {
                    self.contentOffset = CGPointMake(self.contentOffset.x, (self.contentSize.height + 2) - self.height)
                }
            }
            
        }else {
            hasDragging = true
        }
    }
    
}
private var SYKeyboardTextFieldDebugMode : Bool = false

//MARK: UITextView extension
extension UITextView {

    func numberOfLines() -> Int
    {
        let line = self.contentSize.height / self.font!.lineHeight
        if line < 1.0 { return 1 }
        return abs(Int(line))
    }
}
