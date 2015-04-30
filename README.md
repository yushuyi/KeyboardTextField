# SYKeyboardTextField
SYKeyboardTextField 是一个轻巧,简单,非侵入式的键盘附随输入框! 采用Swift编写 
<img src="https://github.com/441088327/SYKeyboardTextField/blob/master/SYKeyboard.gif" width="501" height="538" />


在输入框高度定位方面借鉴了出名的开源库 SlackTextViewController 
不过相对于 SlackTextViewController . SYKeyboardTextField 是一个轻量型的,即插即拔的实现方式.

# iOS Version
iOS 7 以上

# 安装
下载以后拖入项目即可

# 初始化
        keyboardTextField = SYKeyboardTextField(point: CGPointMake(0, 100));
        keyboardTextField.delegate = self
        keyboardTextField.leftButtonHidden = false
        keyboardTextField.rightButtonHidden = false
        keyboardTextField.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin
        self.view.addSubview(keyboardTextField)
        keyboardTextField.toFullyBottom()
