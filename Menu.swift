//
//  Menu.swift
//  RemindMe
//
//  Created by Guilherme Lisboa on 01/05/17.
//  Copyright © 2017 LDevelopment. All rights reserved.
//

import Foundation
import UIKit

typealias MenuSelectionClosure = (Int) -> ()
private let kInitialSpacing: CGFloat = 50
private let kAnimationDuration : CFTimeInterval = 0.5
class Menu: UIView {
    
    private let items: [UIView]
    let menuButton = UIButton()
    private (set) var isOpen: Bool = false
    let itemSize: CGFloat
    let itemSpacing: CGFloat
    var onSelection: MenuSelectionClosure?
    private lazy var menuClosedSize: CGSize = {
        return self.frame.size
    }()

    private var openMenuSize: CGSize {
        return CGSize(width: itemSize * 1.2,
                      height: ((itemSize/2 + itemSpacing) * CGFloat(items.count) + kInitialSpacing) * 2)
    }
    
    
    init(items: [UIView],
         itemSize: CGFloat = 50,
         itemSpacing: CGFloat = 5,
         onSelection: MenuSelectionClosure? = nil) {
        self.items = items
        self.itemSize = itemSize
        self.itemSpacing = itemSpacing
        self.onSelection = onSelection
        super.init(frame: CGRect.zero)
        setupUI()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tapGesture)
        
        items.forEach { (item) in
            item.isUserInteractionEnabled = true
            addSubview(item)
        }
        
        isUserInteractionEnabled = true
        addSubview(menuButton)
        
        menuButton.setImage(UIImage(named: "ic_menu"), for: .normal)
        menuButton.addTarget(self, action: #selector(triggerMenu), for: .touchUpInside)
    }
    
    func onTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        if let view = hitTest(location, with: nil), let index = items.index(of: view) {
            onSelection?(index)
        }
    }
    
    func triggerMenu() {
        
        for (index, item) in items.enumerated() {
            animateItem(item: item, position: index + 1, reverse: isOpen)
        }
        var frame = self.frame
        if isOpen {
            frame.size = menuClosedSize
            self.frame = frame
        } else {
            menuClosedSize = frame.size
            frame.size = openMenuSize
            self.frame = frame
        }
        setNeedsDisplay()
        isOpen = !isOpen
    }
    
    private func createConstraints() {
        menuButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    }
    
    private func animateItem(item: UIView, position: Int, reverse: Bool = false) {
        let arcAnimation = CAKeyframeAnimation(keyPath: "position")
        let sizeAnimation = CAKeyframeAnimation(keyPath: "bounds.size")
        let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        
        arcAnimation.duration = kAnimationDuration
        sizeAnimation.duration = kAnimationDuration
        cornerRadiusAnimation.duration = kAnimationDuration
        
        let radiusOffset = CGFloat(position - 1) * (itemSize/2 + itemSpacing)
        let radius: CGFloat = kInitialSpacing + radiusOffset
        let center = CGPoint(x:itemSize/2,
                             y: radius)
        let topAngle: CGFloat = .pi * 3/2
        let bottomAngle: CGFloat = .pi/2
        let animationSizes = [CGSize(width: 0,
                                     height: 0),
                              CGSize(width: itemSize/2,
                                     height: itemSize/2),
                              CGSize(width: itemSize,
                                     height: itemSize)];
        let path: UIBezierPath
        if reverse {
            path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: bottomAngle,
                                endAngle: topAngle,
                                clockwise: !reverse)
            
            sizeAnimation.values = animationSizes.reversed()
            
            cornerRadiusAnimation.fromValue = itemSize/2
            cornerRadiusAnimation.toValue = 0
            item.layer.frame = CGRect.zero
        } else {
            path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: topAngle,
                                endAngle: bottomAngle,
                                clockwise: !reverse)
            sizeAnimation.values = animationSizes
            
            let cornerRadius = itemSize/2
            cornerRadiusAnimation.fromValue = 0
            cornerRadiusAnimation.toValue = cornerRadius
            item.layer.cornerRadius = cornerRadius
            item.layer.frame = CGRect(x: 0,
                                      y: radius * 2 - itemSize/2,
                                      width: itemSize,
                                      height: itemSize)
        }
        
        arcAnimation.path = path.cgPath
        arcAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let groupedAnimations = CAAnimationGroup()
        
        groupedAnimations.animations = [arcAnimation,
                                        cornerRadiusAnimation,
                                        sizeAnimation];
        groupedAnimations.duration = kAnimationDuration
        groupedAnimations.beginTime = CACurrentMediaTime()
        
        item.layer.add(groupedAnimations, forKey: "arc")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            let isInsideView = self.point(inside: point, with: nil)
            return isInsideView ? self : nil
        }
        return hitView
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if subview.point(inside: point, with: event) {
                return true
            }
        }
        if isOpen {
            var frame = self.frame
            frame.size = openMenuSize
            return frame.contains(point)
        }
        return frame.contains(point)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        centerMenuButton()
    }

    private func centerMenuButton() {
        var menuFrame = menuButton.frame
        menuFrame.origin = CGPoint(x: menuClosedSize.width/2 - menuFrame.size.width/2,
                               y: menuClosedSize.height/2 - menuFrame.size.height/2)
        menuButton.frame = menuFrame
    }
}
