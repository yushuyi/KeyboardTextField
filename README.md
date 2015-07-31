## SYKeyboardTextField
SYKeyboardTextField is a lightweight, simple, non-invasive keyboard accompanying input box! Write in Swift! 

<img src="https://github.com/441088327/SYKeyboardTextField/blob/master/SYKeyboard.gif" width="501" height="538" />

## Requirements

- Swift 2
- iOS 7.0 or later 


## Installation
- Drag the file to your project

- Insert `github "441088327/SYKeyboardTextField"` to your Cartfile.
- Run `carthage update`.


## Usage
        keyboardTextField = SYKeyboardTextField(point: CGPointMake(0, 0), width: self.view.width)
        keyboardTextField.delegate = self
        keyboardTextField.leftButtonHidden = false
        keyboardTextField.rightButtonHidden = false
        keyboardTextField.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
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
        
## Author

[@余书懿](http://weibo.com/ysy441088327)

## License

SYKeyboardTextField is available under the MIT license.
