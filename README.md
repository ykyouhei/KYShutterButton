# KYShutterButton

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Pod Version](http://img.shields.io/cocoapods/v/KYShutterButton.svg?style=flat)](http://cocoadocs.org/docsets/KYShutterButton/) 
[![Pod Platform](http://img.shields.io/cocoapods/p/KYShutterButton.svg?style=flat)](http://cocoadocs.org/docsets/KYShutterButton/)
[![Pod License](http://img.shields.io/cocoapods/l/KYShutterButton.svg?style=flat)](https://github.com/ykyohei/KYShutterButton/blob/master/LICENSE) 
![Swift version](https://img.shields.io/badge/swift-3.1-orange.svg)


`KYShutterButton` is a custom button that is similar to the shutter button of the camera app

* IBDesignable, IBInspectable Support


![sample1.gif](https://cloud.githubusercontent.com/assets/5757351/8271385/a614921e-184f-11e5-9a64-efcd0c1cd0e2.gif "sample.gif") ![sample2.gif](https://cloud.githubusercontent.com/assets/5757351/8271386/aa7808cc-184f-11e5-8766-6c5f56a3d1f0.gif "sample2.gif")


## Installation

### CocoaPods

`KYShutterButton ` is available on CocoaPods.
Add the following to your `Podfile`:

```ruby
pod 'KYShutterButton'
```

### Manually
Just add the Classes folder to your project.


## Usage
(see sample Xcode project in `/Example`)

### Code

```Swift
let shutterButton = KYShutterButton(
	frame: CGRectMake(20, 20, 100, 100),
    shutterType: .Normal,
    buttonColor: UIColor.redColor()
)
shutterButton.addTarget(self,
    action: "didTapButton:",
    forControlEvents: .TouchUpInside
)
/* Custom
shutterButton.arcColor      = UIColor.greenColor()
shutterButton.progressColor = UIColor.yellowColor()
*/
view.addSubview(shutterButton)


func didTapButton(sender: KYShutterButton) {
    switch sender.buttonState {
    case .Normal:
        sender.buttonState = .Recording
    case .Recording:
        sender.buttonState = .Normal
    }
}
```

### Storyboard

![sample3.gif](https://cloud.githubusercontent.com/assets/5757351/8271468/8f97aab2-1854-11e5-87e6-2ac7e17951a7.gif "sample3.gif")


## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 
