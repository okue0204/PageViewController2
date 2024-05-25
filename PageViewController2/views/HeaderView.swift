//
//  HeaderView.swift
//  PageViewController2
//
//  Created by 奥江英隆 on 2024/05/23.
//

import UIKit

class HeaderView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
}
