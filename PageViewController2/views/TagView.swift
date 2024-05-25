//
//  TagView.swift
//  PageViewController2
//
//  Created by 奥江英隆 on 2024/05/23.
//

import UIKit
import Combine

class TagView: UIView {
    
    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.backgroundColor = pageTag.backgroundColor
            backgroundView.layer.cornerRadius = 8
            backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            backgroundView.clipsToBounds = true
        }
    }
    @IBOutlet weak var tagButton: UIButton! {
        didSet {
            tagButton.setTitle(pageTag.title, for: .normal)
        }
    }
    
    private var tagButtonSubject = PassthroughSubject<Int, Never>()
    lazy var tagButtonPublisher = tagButtonSubject.eraseToAnyPublisher()
    
    private let pageTag: ViewController.Tag
    
    init(tag: ViewController.Tag) {
        pageTag = tag
        super.init(frame: .zero)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func didTapTagButton(_ sender: Any) {
        tagButtonSubject.send((pageTag.rawValue))
    }
}
