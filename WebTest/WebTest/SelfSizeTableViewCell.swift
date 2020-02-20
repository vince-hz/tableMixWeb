//
//  SelfSizeTableViewCell.swift
//  WebTest
//
//  Created by xuyunshi on 2019/7/8.
//  Copyright © 2019年 mingdu. All rights reserved.
//

import UIKit

class SelfSizeTableViewCell: UITableViewCell {
    
    var height: CGFloat = 0 {
        didSet {
            textLabel?.text = height.description
            main.snp.updateConstraints { (make) in
                make.height.equalTo(height)
            }
        }
    }
    
    lazy var main = UIView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(main)
        main.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}
