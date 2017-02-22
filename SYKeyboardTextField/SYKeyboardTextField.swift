//
//  SYKeyboardTextField.swift
//  DoudouApp
//  Version 3.1 iOS 8.0 and Swift 3 and Xcode8.2
//  Created by yushuyi on 15/1/17.
//  Copyright (c) 2015年 DoudouApp. All rights reserved.
//

import UIKit

@objc public protocol SYKeyboardTextFieldDelegate : class {

    /**
    点击左边按钮的委托
    */
    @objc optional func keyboardTextFieldPressLeftButton(_ keyboardTextField :SYKeyboardTextField)
   
    /**
    点击右边按钮的委托
    */
    @objc optional func keyboardTextFieldPressRightButton(_ keyboardTextField :SYKeyboardTextField)

    /**
    点击键盘上面的回车按钮响应委托
    */
    @objc optional func keyboardTextFieldPressReturnButton(_ keyboardTextField :SYKeyboardTextField)
    
    @objc optional func keyboardTextFieldWillBeginEditing(_ keyboardTextField :SYKeyboardTextField)
    @objc optional func keyboardTextFieldDidBeginEditing(_ keyboardTextField :SYKeyboardTextField)

    @objc optional func keyboardTextFieldWillEndEditing(_ keyboardTextField :SYKeyboardTextField)
    @objc optional func keyboardTextFieldDidEndEditing(_ keyboardTextField :SYKeyboardTextField)

    
    /**
    键盘文本内容被改变时触发
    - parameter text:              本次写入的值
    */
    @objc optional func keyboardTextField(_ keyboardTextField :SYKeyboardTextField , didChangeText text:String)

}

fileprivate var SYKeyboardTextFieldDebugMode : Bool = false

fileprivate var keyboardViewDefaultHeight : CGFloat = 48.0
fileprivate let textViewDefaultHeight : CGFloat = 36.0




open class SYKeyboardTextField: UIView {

    //Delegate
    open weak var delegate : SYKeyboardTextFieldDelegate?
    
    //Init
    public convenience init(point : CGPoint,width : CGFloat) {
        self.init(frame: CGRect(x: point.x, y: point.y, width: width, height: keyboardViewDefaultHeight))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame : CGRect) {
        super.init(frame : frame)
        keyboardViewDefaultHeight = frame.height
        backgroundColor = UIColor.red
        
        keyboardView.frame = bounds
        keyboardView.backgroundColor = UIColor.yellow
        addSubview(keyboardView)
        
        keyboardView.addSubview(textViewBackground)
        
        textView.font = UIFont.systemFont(ofSize: 15.0);
        //        textView.autocapitalizationType = UITextAutocapitalizationType.Sentences
        textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, -1, 0, 1);//滚动指示器 皮条
        textView.textContainerInset = UIEdgeInsetsMake(9.0, 3.0, 7.0, 0.0);
        textView.autocorrectionType = .no
        textView.keyboardType = UIKeyboardType.default;
        textView.returnKeyType = UIReturnKeyType.send;
        textView.enablesReturnKeyAutomatically = true;
        
        textView.delegate = self
        textView.textColor = UIColor(white: 0.200, alpha: 1.000)
        textView.backgroundColor = UIColor.green
        textView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        textView.scrollsToTop = false
        keyboardView.addSubview(textView)
        
        placeholderLabel.textAlignment = NSTextAlignment.left
        placeholderLabel.numberOfLines = 1
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.font = textView.font;
        placeholderLabel.isHidden = false
        placeholderLabel.text = "placeholder"
        textView.addSubview(placeholderLabel)
        
        
        leftButton.backgroundColor = UIColor.red
        leftButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        leftButton.setTitle("Left", for: .normal)
        leftButton.addTarget(self, action: #selector(SYKeyboardTextField.leftButtonAction(_:)), for: UIControlEvents.touchUpInside)
        keyboardView.addSubview(leftButton)
        
        rightButton.backgroundColor = UIColor.red
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        rightButton.setTitle("Right", for: .normal)
        rightButton.addTarget(self, action: #selector(SYKeyboardTextField.rightButtonAction(_:)), for: UIControlEvents.touchUpInside)
        keyboardView.addSubview(rightButton)
        
        registeringKeyboardNotification()
        
    }

    open func show() {
        textView.becomeFirstResponder()
    }
    
    open func hide() {
        attachmentView?.moveToBottom()
        delegate?.keyboardTextFieldWillEndEditing?(self)
        isEditing = false
        isHideing = true
        endEditing(true)
        setTapButtonHidden(true)
    }
    
    open func addAttachmentView(_ view: UIView) {
        removeAttachmentView()
        insertSubview(view, at: 0)
        view.alpha = 0
        view.isUserInteractionEnabled = false
        view.autoresizingMask = []
        attachmentView = view
    }
    
    public func removeAttachmentView() {
        if let attachmentView = attachmentView {
            attachmentView.removeFromSuperview()
            self.attachmentView = nil
        }
    }
    
    //Status
    public var isSending = false
    
    public var isEnabled: Bool = true {
        didSet {
            textView.isEditable = isEnabled
            leftButton.isEnabled = isEnabled
            rightButton.isEnabled = isEnabled
        }
    }
    public var isEditing: Bool = false
    
    public var isLeftButtonHidden : Bool = true {
        didSet {
            leftButton.isHidden = isLeftButtonHidden
            setNeedsLayout()
        }
    }
    
    public var isRightButtonHidden : Bool = true {
        didSet {
            rightButton.isHidden = isRightButtonHidden
            setNeedsLayout()
        }
    }
    
    //text
    public var text : String! {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            textViewDidChange(textView)
            layoutIfNeeded()
        }
    }
    
    open var maxNumberOfWords : Int = 140
    open var minNumberOfWords : Int = 0
    open var maxNumberOfLines : Int = 4
    
    
    //UI
    public var attachmentView: UIView?
    public lazy var keyboardView = UIView()
    public lazy var textView : SYKeyboardTextView = SYKeyboardTextView()
    public lazy var placeholderLabel = UILabel()
    public lazy var textViewBackground = UIImageView()
    public lazy var leftButton = UIButton()
    public lazy var rightButton = UIButton()
    public func clearTestColor() {
        backgroundColor = UIColor.clear
        leftButton.backgroundColor = UIColor.clear
        rightButton.backgroundColor = UIColor.clear
        textView.backgroundColor = UIColor.clear
        textViewBackground.backgroundColor = UIColor.clear
    }
    

    //Layout
    fileprivate var lastKeyboardFrame : CGRect = CGRect.zero

    open var leftRightDistance : CGFloat = 8.0
    open var middleDistance : CGFloat = 8.0

    open var buttonMaxWidth : CGFloat = 65.0
    open var buttonMinWidth : CGFloat = 45.0
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if isEditing {
            keyboardView.frame = CGRect(x: 0, y: (attachmentView?.bounds.size.height ?? 0), width: bounds.size.width, height: bounds.size.height - (attachmentView?.bounds.size.height ?? 0))
        }else {
            keyboardView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        }
        
        if isLeftButtonHidden == false {
            var leftButtonWidth : CGFloat = 0.0
            leftButton.sizeToFit()
            if (buttonMinWidth <= leftButton.bounds.size.width) {
                leftButtonWidth = leftButton.bounds.size.width + 10
            }else {
                leftButtonWidth = buttonMinWidth
            }
            if (leftButton.bounds.size.width > buttonMaxWidth)
            {
                leftButtonWidth = buttonMaxWidth
            }
            leftButton.frame = CGRect(x: leftRightDistance, y: 0, width: leftButtonWidth, height: textViewDefaultHeight);
            leftButton.ktf_toBottom(offset: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0)
        }
        
        if isRightButtonHidden == false {
            var rightButtonWidth : CGFloat = 0.0
            rightButton.sizeToFit()
            if (buttonMinWidth <= rightButton.bounds.size.width) {
                rightButtonWidth = rightButton.bounds.size.width + 10;
            }else {
                rightButtonWidth = buttonMinWidth
            }
            if (rightButton.bounds.size.width > buttonMaxWidth)
            {
                rightButtonWidth = buttonMaxWidth;
            }
            rightButton.frame = CGRect(x: keyboardView.bounds.size.width - leftRightDistance - rightButtonWidth, y: 0, width: rightButtonWidth, height: textViewDefaultHeight);
            rightButton.ktf_toBottom(offset: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0)
        }
        
        textView.frame =
            CGRect(
                x: (isLeftButtonHidden == false ? leftButton.frame.origin.x + leftButton.bounds.size.width + middleDistance : leftRightDistance + middleDistance),
                y: (keyboardViewDefaultHeight - textViewDefaultHeight) / 2.0 + 0.5,
                width: keyboardView.bounds.size.width
                    - (isLeftButtonHidden == false ? leftButton.bounds.size.width + middleDistance:middleDistance)
                    - (isRightButtonHidden == false ? rightButton.bounds.size.width + middleDistance:middleDistance)
                    - leftRightDistance * 2,
                height:
                textView.ktf_numberOfLines() < maxNumberOfLines ?
                textViewCurrentHeightForLines(textView.ktf_numberOfLines()) :
                textViewCurrentHeightForLines(maxNumberOfLines)
        )
        textViewBackground.frame = textView.frame;
        
        if placeholderLabel.textAlignment == .left {
            placeholderLabel.sizeToFit()
            placeholderLabel.frame.origin = CGPoint(x: 8.0, y: (textViewDefaultHeight - placeholderLabel.bounds.size.height) / 2);
            
        }else if placeholderLabel.textAlignment == .center {
           placeholderLabel.frame = placeholderLabel.superview!.bounds
        }
        
        
        if let attachmentView = attachmentView {
            attachmentView.bounds.size.width = bounds.size.width
            attachmentView.frame.origin = CGPoint.zero
        }

    }
 
    deinit {
        if SYKeyboardTextFieldDebugMode {
            print("\(NSStringFromClass(classForCoder)) has release!")
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate var isHideing = false
    fileprivate var isShowing = false
}

//MARK: TextViewHeight
extension SYKeyboardTextField {

    fileprivate func textViewCurrentHeightForLines(_ numberOfLines : Int) -> CGFloat {
        var height = textViewDefaultHeight - textView.font!.lineHeight
        let lineTotalHeight = textView.font!.lineHeight * CGFloat(numberOfLines)
        height += CGFloat(roundf(Float(lineTotalHeight)))
        return CGFloat(Int(height));
    }
    
    fileprivate func appropriateInputbarHeight() -> CGFloat {
        var height : CGFloat = 0.0;
        
        if textView.ktf_numberOfLines() == 1 {
            height = textViewDefaultHeight;
        }else if textView.ktf_numberOfLines() < maxNumberOfLines {
            height = textViewCurrentHeightForLines(textView.ktf_numberOfLines())
        }
        else {
            height = textViewCurrentHeightForLines(maxNumberOfLines)
        }
        
        height += keyboardViewDefaultHeight - textViewDefaultHeight;
        
        if (height < keyboardViewDefaultHeight) {
            height = keyboardViewDefaultHeight;
        }
        return CGFloat(roundf(Float(height)));
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let object = object as? SYKeyboardTextView,let change = change else { return }
        
        if object == textView && keyPath == "contentSize" {
            if SYKeyboardTextFieldDebugMode {
                if let sizeValue = (change[NSKeyValueChangeKey.newKey] as? NSValue)?.cgSizeValue {
                    print("\(sizeValue)---\(appropriateInputbarHeight())")
                }
            }
            
            let newKeyboardHeight = appropriateInputbarHeight()
            if newKeyboardHeight != keyboardView.bounds.size.height && superview != nil {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
                    let lastKeyboardFrameHeight = (self.lastKeyboardFrame.origin.y == 0.0 ? self.superview!.bounds.size.height : self.lastKeyboardFrame.origin.y)
                    if self.isEditing {
                        self.frame = CGRect(x: self.frame.origin.x,  y: lastKeyboardFrameHeight - newKeyboardHeight - (self.attachmentView?.bounds.size.height ?? 0), width: self.frame.size.width, height: newKeyboardHeight + (self.attachmentView?.bounds.size.height ?? 0))
                    }else {
                        self.frame = CGRect(x: self.frame.origin.x,  y: lastKeyboardFrameHeight - newKeyboardHeight, width: self.frame.size.width, height: newKeyboardHeight)
                    }
                    
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
    var keyboardAnimationDuration : TimeInterval {
        return  TimeInterval(0.25)
    }
    
    func registeringKeyboardNotification() {
        //  Registering for keyboard notification.
        
        NotificationCenter.default.addObserver(self, selector: #selector(SYKeyboardTextField.keyboardWillChangeFrame(_:)),name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SYKeyboardTextField.keyboardDidChangeFrame(_:)),name:NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
        
        //  Registering for orientation changes notification
        NotificationCenter.default.addObserver(self, selector: #selector(SYKeyboardTextField.willChangeStatusBarOrientation(_:)),name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
    
    }
    
    func keyboardWillChangeFrame(_ notification : Notification) {
        if window == nil { return }
        if !window!.isKeyWindow { return }
        
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = keyboardFrameValue.cgRectValue
        lastKeyboardFrame = superview!.convert(keyboardFrame, from: UIApplication.shared.keyWindow)
        if SYKeyboardTextFieldDebugMode {
            print("keyboardFrame : \(keyboardFrame)")
        }
        
        UIView.animate(withDuration: keyboardAnimationDuration, delay: 0.0, options: keyboardAnimationOptions, animations: { () -> Void in
            if self.isEditing {
                self.frame.origin.y = self.lastKeyboardFrame.origin.y - self.keyboardView.bounds.size.height - (self.attachmentView?.bounds.size.height ?? 0)
                self.frame.size.height = self.keyboardView.bounds.size.height + (self.attachmentView?.bounds.size.height ?? 0)
                self.attachmentView?.alpha = 1
                self.attachmentView?.isUserInteractionEnabled = true
            }else {
                self.frame.origin.y = self.superview!.bounds.size.height - self.keyboardView.bounds.size.height
                self.frame.size.height = self.keyboardView.bounds.size.height
                self.keyboardView.frame = self.bounds
                self.attachmentView?.alpha = 0
                self.attachmentView?.isUserInteractionEnabled = false
            }
            
        }, completion: {_ in
            if !self.isEditing && self.isHideing {
                self.isHideing = false
                self.delegate?.keyboardTextFieldDidEndEditing?(self)
            }
            if self.isEditing && self.isShowing {
                self.attachmentView?.moveToTop()
                
                self.isShowing = false
                self.delegate?.keyboardTextFieldDidBeginEditing?(self)
            }
        })
    }
    
    func keyboardDidChangeFrame(_ notification : Notification) {}
    func willChangeStatusBarOrientation(_ notification : Notification) {}

}


//MARK: TapButtonAction
extension SYKeyboardTextField {
    
    @objc func leftButtonAction(_ button : UIButton) {
        delegate?.keyboardTextFieldPressLeftButton?(self)
    }
    
    @objc func rightButtonAction(_ button : UIButton) {
        delegate?.keyboardTextFieldPressRightButton?(self)
    }
    
    fileprivate var tapButtonTag : Int { return 12345 }
    fileprivate var tapButton : UIButton { return superview!.viewWithTag(tapButtonTag) as! UIButton }
    @objc func tapAction(_ button : UIButton) {
        hide()
    }
    
    fileprivate func setTapButtonHidden(_ hidden : Bool) {
        tapButton.isHidden = hidden
        if hidden == false {
            if let tapButtonSuperView = tapButton.superview {
                tapButtonSuperView.insertSubview(tapButton, belowSubview: self)
            }
        }
    }
    
    override open func didMoveToSuperview() {
        if let superview = superview {
            let tapButton = UIButton(frame: superview.bounds)
            tapButton.addTarget(self, action: #selector(SYKeyboardTextField.tapAction(_:)), for: UIControlEvents.touchUpInside)
            tapButton.tag = tapButtonTag
            tapButton.isHidden = true
            tapButton.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            tapButton.backgroundColor = UIColor.clear
            superview.insertSubview(tapButton, at: 0);
        }
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        if ((superview != nil) && newSuperview == nil) {
            superview?.viewWithTag(tapButtonTag)?.removeFromSuperview()
            textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
        }
    }
}


//MARK: UITextViewDelegate
extension SYKeyboardTextField : UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        
        if (textView.text.characters.isEmpty) {
            placeholderLabel.alpha = 1
        }
        else {
            placeholderLabel.alpha = 0
        }
        
        delegate?.keyboardTextField?(self, didChangeText: textView.text)
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if isEditing == false {
            isShowing = true
            delegate?.keyboardTextFieldWillBeginEditing?(self)
        }
        isEditing = true
        setTapButtonHidden(false)
        return true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if isSending { return false }
        if text == "\n" {
            if isSending == false {
                delegate?.keyboardTextFieldPressReturnButton?(self)
            }
            return false
        }
        return true
    }
}

extension SYKeyboardTextField {
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let attachmentView = attachmentView {
            if (attachmentView.frame.contains(point)) {
                return attachmentView.point(inside: point, with: event)
            }
        }
        return super.point(inside: point, with: event)
    }
}

public final class SYKeyboardTextView : UITextView {
    
    private var hasDragging : Bool = false
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if isDragging == false {
            if hasDragging {
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    self.hasDragging = false
                }
            }else {
                if selectedRange.location == text.characters.count {
                    contentOffset = CGPoint(x: contentOffset.x, y: (contentSize.height + 2) - bounds.size.height)
                }
            }
        }else {
            hasDragging = true
        }
    }
    
}

//MARK: UITextView extension
extension UITextView {
    
    fileprivate func ktf_numberOfLines() -> Int {
        let text = self.text as NSString
        let textAttributes = [NSFontAttributeName: font!]
        var width: CGFloat = UIEdgeInsetsInsetRect(frame, textContainerInset).width
        width -= 2.0 * textContainer.lineFragmentPadding
        let boundingRect: CGRect = text.boundingRect(with: CGSize(width:width,height:9999), options: [NSStringDrawingOptions.usesLineFragmentOrigin , NSStringDrawingOptions.usesFontLeading], attributes: textAttributes, context: nil)
        let line = boundingRect.height / font!.lineHeight
        if line < 1.0 { return 1 }
        return abs(Int(line))
    }
}

extension UIView {
    /**
     将视图移动到父视图的底端
     - parameter offset: 可进行微调 大于0 则  小于0 则
     */
    fileprivate func ktf_toBottom(offset : CGFloat = 0.0) {
        if let superView = superview {
            frame.origin.y = superView.bounds.size.height - offset - frame.size.height;
        }else {
            print("UIView+SYAutoLayout toBottom 没有 superview");
        }
    }
    
    public func moveToTop() {
        superview?.bringSubview(toFront: self)
    }
    
    public func moveToBottom() {
        superview?.sendSubview(toBack: self)
    }
}
