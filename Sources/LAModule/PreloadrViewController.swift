//
//  PreloadrViewController.swift
//  Mini Slots Game
//
//  Created by ankudinov aleksandr on 03.08.2023.
//

import UIKit
import SwiftUI

public class PreloadrViewController:UIViewController{
    
    var progressView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var hostingView:Any?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        var launchScreenView:UIView?
        
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        if let vc = storyboard.instantiateInitialViewController() {
            self.addChild(vc)
            self.view.addSubview(vc.view)
            launchScreenView = vc.view
        }
        
        self.view.addSubview(progressView)
        animationHorizontalCirclesPulse(progressView);
        setContraints(launchScreenView)
    }

    private func setContraints(_ launchScreenView:UIView?) {
    
        if let launchView = launchScreenView {
            launchView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                launchView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                launchView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                launchView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                launchView.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        }
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
      
        NSLayoutConstraint.activate([
            progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            progressView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 50)
        ])
    
    }
    
    private func animationLineScaling(_ view: UIView) {

        let width = view.frame.size.width
        let height = view.frame.size.height

        let lineWidth = width / 9

        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.5, 0.4, 0.3, 0.2, 0.1]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)

        let animation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.4, 1]
        animation.duration = 1
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: lineWidth, height: height), cornerRadius: width / 2)

        for i in 0..<5 {
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: lineWidth * 2 * CGFloat(i), y: 0, width: lineWidth, height: height)
            layer.path = path.cgPath
            layer.backgroundColor = nil
            layer.fillColor = UIColor.lightGray.cgColor

            animation.beginTime = beginTime - beginTimes[i]

            layer.add(animation, forKey: "animation")
            view.layer.addSublayer(layer)
        }
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
                layer.fillColor = UIColor.lightGray.cgColor

                animation.beginTime = beginTime - beginTimes[i]

                layer.add(animation, forKey: "animation")
                view.layer.addSublayer(layer)
            }
        }
    
    public func showSwiftUI(view:some View){
        let vc = UIHostingController(rootView: view)
        hostingView = vc
        vc.modalPresentationStyle = .fullScreen
        
        if let window = UIApplication.shared.delegate?.window {
            UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true,completion: {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false)
            })
        } else {
            self.present(vc, animated: false)
        }
    }
    
    public func hideSwiftUI(){
        if hostingView != nil {
            self.dismiss(animated: false)
            hostingView = nil
        }
    }
}
