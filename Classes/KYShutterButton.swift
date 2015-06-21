/*
The MIT License (MIT)

Copyright (c) 2015 Kyohei Yamaguchi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import UIKit

@IBDesignable
public class KYShutterButton: UIButton {
    
    public enum ShutterType: Int {
        case Normal, SlowMotion, TimeLapse
    }
    
    public enum ButtonState: Int {
        case Normal, Recording
    }
    
    private let _kstartAnimateDuration: CFTimeInterval = 0.5
    
    /**************************************************************************/
    // MARK: - Properties
    /**************************************************************************/
    
    @IBInspectable var typeRaw: Int = 0 {
        didSet {
            if let type = ShutterType(rawValue: typeRaw) {
                self.shutterType = type
            } else {
                self.shutterType = .Normal
            }
        }
    }
    
    @IBInspectable public var buttonColor: UIColor = UIColor.redColor() {
        didSet {
            _circleLayer.backgroundColor = buttonColor.CGColor
        }
    }
    
    @IBInspectable public var arcColor: UIColor = UIColor.whiteColor() {
        didSet {
            _arcLayer.strokeColor = arcColor.CGColor
        }
    }
    
    @IBInspectable public var progressColor: UIColor = UIColor.whiteColor() {
        didSet {
            _progressLayer.strokeColor = progressColor.CGColor
            _rotateLayer.strokeColor   = progressColor.CGColor
        }
    }
    
    public var buttonState: ButtonState = .Normal {
        didSet {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = _circleLayer.path
            animation.duration  = 0.15
            
            switch buttonState {
            case .Normal:
                if shutterType == .TimeLapse {
                    _progressLayer.removeAllAnimations()
                    _rotateLayer.removeAllAnimations()
                }
                animation.toValue = _circlePath.CGPath
                _circleLayer.addAnimation(animation, forKey: "path-anim")
                _circleLayer.path = _circlePath.CGPath
            case .Recording:
                animation.toValue = _roundRectPath.CGPath
                _circleLayer.addAnimation(animation, forKey: "path-anim")
                _circleLayer.path = _roundRectPath.CGPath
                if shutterType == .TimeLapse {
                    _progressLayer.addAnimation(_startProgressAnimation, forKey: "start-anim")
                    _rotateLayer.addAnimation(_startRotateAnimation, forKey: "rotate-anim")
                    _progressLayer.addAnimation(_recordingAnimation, forKey: "recording-anim")
                    _rotateLayer.addAnimation(_recordingRotateAnimation, forKey: "recordingRotate-anim")
                    _progressLayer.path = p_arcPathWithProgress(1.0).CGPath
                }
            }
        }
    }
    
    public var shutterType: ShutterType  = .Normal {
        didSet {
            switch shutterType {
            case .Normal:
                _arcLayer.lineDashPattern = nil
                _progressLayer.hidden     = true
            case .SlowMotion:
                _arcLayer.lineDashPattern = [1, 1]
                _progressLayer.hidden     = true
            case .TimeLapse:
                let diameter = 2*CGFloat(M_PI)*(self.bounds.width/2 - self._arcWidth/2)
                _arcLayer.lineDashPattern = [1, diameter/10 - 1]
                _progressLayer.hidden     = false
            }
        }
    }
    
    private var _arcWidth: CGFloat {
        return bounds.width * 0.09090
    }
    
    private var _arcMargin: CGFloat {
        return bounds.width * 0.03030
    }
    
    lazy private var _circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path      = self._circlePath.CGPath
        layer.fillColor = self.buttonColor.CGColor
        return layer
    }()
    
    lazy private var _arcLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let path  = UIBezierPath(
            arcCenter: CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)),
            radius: self.bounds.width/2 - self._arcWidth/2,
            startAngle: -CGFloat(M_PI_2),
            endAngle: CGFloat(M_PI*2.0) - CGFloat(M_PI_2),
            clockwise: true
        )
        layer.path        = path.CGPath
        layer.fillColor   = UIColor.clearColor().CGColor
        layer.strokeColor = self.arcColor.CGColor
        layer.lineWidth   = self._arcWidth
        return layer
    }()
    
    lazy private var _progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let path  = self.p_arcPathWithProgress(1.0, clockwise: true)
        let diameter = 2*CGFloat(M_PI)*(self.bounds.width/2 - self._arcWidth/3)
        layer.lineDashPattern = [1, diameter/60 - 1]
        layer.path            = path.CGPath
        layer.fillColor       = UIColor.clearColor().CGColor
        layer.strokeColor     = self.progressColor.CGColor
        layer.lineWidth       = self._arcWidth/1.5
        return layer
    }()
    
    lazy private var _rotateLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let subPath = UIBezierPath()
        subPath.moveToPoint(CGPointMake(self.bounds.width/2, 0))
        subPath.addLineToPoint(CGPointMake(self.bounds.width/2, self._arcWidth))
        layer.strokeColor = self.progressColor.CGColor
        layer.lineWidth   = 1
        layer.path        = subPath.CGPath
        layer.frame       = self.bounds
        return layer
    }()
    
    private var _circlePath: UIBezierPath {
        let side = self.bounds.width - self._arcWidth*2 - self._arcMargin*2
        return UIBezierPath(
            roundedRect: CGRectMake(bounds.width/2 - side/2, bounds.width/2 - side/2, side, side),
            cornerRadius: side/2
        )
    }
    
    private var _roundRectPath: UIBezierPath {
        let side = bounds.width * 0.4242
        return UIBezierPath(
            roundedRect: CGRectMake(bounds.width/2 - side/2, bounds.width/2 - side/2, side, side),
            cornerRadius: side * 0.107
        )
    }
    
    private var _startProgressAnimation: CAKeyframeAnimation {
        let frameCount = 60
        var paths = [CGPath]()
        var times = [CGFloat]()
        for i in 1...frameCount {
            let animationProgress = 1/CGFloat(frameCount) * CGFloat(i) - 0.01
            paths.append(self.p_arcPathWithProgress(animationProgress, clockwise: false).CGPath)
            times.append(CGFloat(i)*0.1)
        }
        let animation         = CAKeyframeAnimation(keyPath: "path")
        animation.duration    = _kstartAnimateDuration
        animation.values      = paths
        return animation
    }
    
    private var _startRotateAnimation: CABasicAnimation {
        let animation         = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue   = 0
        animation.toValue     = CGFloat(M_PI*2.0)
        animation.duration    = _kstartAnimateDuration
        return animation
    }
    
    private var _recordingAnimation: CAKeyframeAnimation {
        let frameCount = 60
        var paths = [CGPath]()
        for i in 1...frameCount {
            let animationProgress = 1/CGFloat(frameCount) * CGFloat(i)
            paths.append(self.p_arcPathWithProgress(animationProgress).CGPath)
        }
        for i in 1...frameCount {
            let animationProgress = 1/CGFloat(frameCount) * CGFloat(i) - 0.01
            paths.append(self.p_arcPathWithProgress(animationProgress, clockwise: false).CGPath)
        }
        let animation         = CAKeyframeAnimation(keyPath: "path")
        animation.duration    = 10
        animation.values      = paths
        animation.beginTime   = CACurrentMediaTime() + _kstartAnimateDuration
        animation.repeatCount = Float.infinity
        animation.calculationMode = kCAAnimationDiscrete
        return animation
    }
    
    private var _recordingRotateAnimation: CABasicAnimation {
        let animation         = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue   = 0
        animation.toValue     = CGFloat(M_PI*2.0)
        animation.duration    = 5
        animation.repeatCount = Float.infinity
        animation.beginTime   = CACurrentMediaTime() + _kstartAnimateDuration
        return animation
    }
    
    
    /**************************************************************************/
    // MARK: - initialize
    /**************************************************************************/
    
    public convenience init(frame: CGRect, shutterType: ShutterType, buttonColor: UIColor) {
        self.init(frame: frame)
        self.shutterType = shutterType
        self.buttonColor = buttonColor
    }
    
    /**************************************************************************/
    // MARK: - Override
    /**************************************************************************/
    
    override public var highlighted: Bool {
        didSet {
            _circleLayer.opacity = highlighted ? 0.5 : 1.0
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if _arcLayer.superlayer != layer {
            layer.addSublayer(_arcLayer)
        }
        if _progressLayer.superlayer != layer {
            layer.addSublayer(_progressLayer)
        }
        if _rotateLayer.superlayer != layer {
            layer.insertSublayer(_rotateLayer, atIndex: 0)
        }
        if _circleLayer.superlayer != layer {
            layer.addSublayer(_circleLayer)
        }
    }
    
    /**************************************************************************/
    // MARK: - Method
    /**************************************************************************/
    
    private func p_arcPathWithProgress(progress: CGFloat, clockwise: Bool = true) -> UIBezierPath {
        let diameter = 2*CGFloat(M_PI)*(self.bounds.width/2 - self._arcWidth/3)
        let startAngle = clockwise ?
            -CGFloat(M_PI_2) :
            -CGFloat(M_PI_2) + CGFloat(M_PI)*(540/diameter)/180
        let endAngle   = clockwise ?
            CGFloat(M_PI*2.0)*progress - CGFloat(M_PI_2) :
            CGFloat(M_PI*2.0)*progress - CGFloat(M_PI_2) + CGFloat(M_PI)*(540/diameter)/180
        let path = UIBezierPath(
            arcCenter: CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)),
            radius: self.bounds.width/2 - self._arcWidth/3,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: clockwise
        )
        return path
    }

}
