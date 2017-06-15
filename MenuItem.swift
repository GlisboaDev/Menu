//
//  MenuItem.swift
//  RemindMe
//
//  Created by Guilherme Lisboa on 03/05/17.
//  Copyright © 2017 LDevelopment. All rights reserved.
//

import UIKit

class MenuItem: UIImageView {
    
    private let labelTitle = UILabel()
    
    init(image: UIImage? = nil, title: NSAttributedString) {
        super.init(frame: CGRect.zero)
        labelTitle.attributedText = title
        self.image = image
        setupUI()
    }
    
    private func setupUI() {
        addSubview(labelTitle)
        backgroundColor = UIColor.white
        contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        labelTitle.sizeToFit()
        labelTitle.frame.origin = CGPoint(x: frame.size.width + 5, y: frame.size.height/2 - labelTitle.frame.size.height/2)
        labelTitle.isHidden = frame.size == CGSize.zero
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
