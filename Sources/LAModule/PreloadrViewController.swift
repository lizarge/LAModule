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
        self.view.addSubview(progressView)
        progressView.center = self.view.center
        animationLineScaling(progressView);
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        progressView.center = self.view.center
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
