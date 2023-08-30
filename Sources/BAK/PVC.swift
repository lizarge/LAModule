//
//  PreloadrViewController.swift
//  Mini Slots Game
//
//  Created by ankudinov aleksandr on 03.08.2023.
//

import UIKit
import SwiftUI

public class PVC:UIViewController{
    
    private var progressView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    private var hostingView:UIViewController?
    private var launchScreenView:UIView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            self.addChild(vc)
            self.view.addSubview(vc.view)
            self.launchScreenView = vc.view
        }
        
        self.view.addSubview(progressView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.animationMultipleCirclePulse(self.progressView);
        }
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        launchScreenView?.frame = self.view.frame
        progressView.center = self.view.center
        progressView.center.y = 100
    }
    
    private func animationHorizontalCirclesPulse(_ view: UIView) {

            let width = view.frame.size.width
            let height = view.frame.size.height

            let spacing = 3.0
            let radius = (width - spacing * 2) / 3
            let center = CGPoint(x: radius / 2, y: radius / 2)
            let positionY = (height - radius) / 2

            let beginTime = CACurrentMediaTime()
            let beginTimes = [0.36, 0.24, 0.12]
            let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)

            let animation = CAKeyframeAnimation(keyPath: "transform.scale")
            animation.keyTimes = [0, 0.5, 1]
            animation.timingFunctions = [timingFunction, timingFunction]
            animation.values = [1, 0.3, 1]
            animation.duration = 1
            animation.repeatCount = HUGE
            animation.isRemovedOnCompletion = false

            let path = UIBezierPath(arcCenter: center, radius: radius / 2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)

            for i in 0..<3 {
                let layer = CAShapeLayer()
                layer.frame = CGRect(x: (radius + spacing) * CGFloat(i), y: positionY, width: radius, height: radius)
                layer.path = path.cgPath
                layer.fillColor = UIColor.white.cgColor

                animation.beginTime = beginTime - beginTimes[i]

                layer.add(animation, forKey: "animation")
                view.layer.addSublayer(layer)
            }
        }
    
    //-------------------------------------------------------------------------------------------------------------------------------------------
        private func animationMultipleCirclePulse(_ view: UIView) {

            let width = view.frame.size.width
            let height = view.frame.size.height
            let center = CGPoint(x: width / 2, y: height / 2)
            let radius = width / 2

            let duration = 1.0
            let beginTime = CACurrentMediaTime()
            let beginTimes = [0, 0.3, 0.6]

            let animationScale = CABasicAnimation(keyPath: "transform.scale")
            animationScale.duration = duration
            animationScale.fromValue = 0
            animationScale.toValue = 1

            let animationOpacity = CAKeyframeAnimation(keyPath: "opacity")
            animationOpacity.duration = duration
            animationOpacity.keyTimes = [0, 0.05, 1]
            animationOpacity.values = [0, 1, 0]

            let animation = CAAnimationGroup()
            animation.animations = [animationScale, animationOpacity]
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = duration
            animation.repeatCount = HUGE
            animation.isRemovedOnCompletion = false

            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)

            for i in 0..<3 {
                let layer = CAShapeLayer()
                layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
                layer.path = path.cgPath
                layer.fillColor = UIColor.white.cgColor
                layer.opacity = 0

                animation.beginTime = beginTime + beginTimes[i]

                layer.add(animation, forKey: "animation")
                view.layer.addSublayer(layer)
            }
        }
    
    public func showSwiftUI(view:some View){
        let vc = UIHostingController(rootView: view)
        hostingView = vc
        vc.view.frame = self.view.frame
        
        UIView.transition(with: self.view, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.addChild(vc)
            self.view.addSubview(vc.view)
        }, completion: nil)
    }
    
    public func hideSwiftUI(){
        if hostingView != nil {
            hostingView?.view.removeFromSuperview()
            hostingView?.removeFromParent()
            hostingView = nil
        }
    }
}

struct Empty: View {
    var body: some View {
        Text("one")
    }
}
