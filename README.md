<p align="center">
<img src="https://github.com/441088327/SYKeyboardTextField/blob/master/logo.png" alt="" />
</p>

KeyboardTextField is a lightweight, simple, non-invasive keyboard accompanying input box! Write in Swift! 

<img src="https://github.com/441088327/SYKeyboardTextField/blob/master/SYKeyboard.gif" width="501" height="538" />

## Requirements

- Swift 4
- iOS 8.0 or later 


## Installation
- Drag the file to your project

## Usage
        keyboardTextField = KeyboardTextField(point: CGPoint(x: 0, y: 0), width: self.view.bounds.size.width)
        keyboardTextField.delegate = self
        keyboardTextField.isLeftButtonHidden = false
        keyboardTextField.isRightButtonHidden = false
        keyboardTextField.autoresizingMask = [UIViewAutoresizing.flexibleWidth , UIViewAutoresizing.flexibleTopMargin]
        self.view.addSubview(keyboardTextField)
        keyboardTextField.toFullyBottom()
## How to custom UI Style ?
        //UI
        lazy var keyboardView = UIView()
        lazy var textView : SYKeyboardTextView = SYKeyboardTextView()
        lazy var placeholderLabel = UILabel()
        lazy var textViewBackground = UIImageView()
        lazy var leftButton = UIButton()
        lazy var rightButton = UIButton()

 <img src="https://github.com/441088327/SYKeyboardTextField/blob/master/style.png" width="375" height="667" />
       
## Author

[@余书懿](http://weibo.com/ysy441088327)

## License

KeyboardTextField is available under the MIT license.
