//
//  ViewController.swift
//  PageViewController2
//
//  Created by 奥江英隆 on 2024/05/23.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    enum Tag: Int, CaseIterable {
        case number1 = 0
        case number2
        case number3
        case number4
        case number5
        case number6
        case number7
        
        var title: String {
            switch self {
            case .number1:
                "number1"
            case .number2:
                "number2"
            case .number3:
                "number3"
            case .number4:
                "number4"
            case .number5:
                "number5"
            case .number6:
                "number6"
            case .number7:
                "number7"
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .number1:
                UIColor.tagRed
            case .number2:
                UIColor.tagOrange
            case .number3:
                UIColor.tagGreen
            case .number4:
                UIColor.tagBlue
            case .number5:
                UIColor.tagPurple
            case .number6:
                UIColor.tagRed
            case .number7:
                UIColor.tagOrange
            }
        }
    }

    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var pageContainerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var tagBoaderView: UIView!
    
    private static let defaultTranslationY: CGFloat = -5
    
    private let viewControllers: [UIViewController] = [
        UIStoryboard.number1Storyboard.instantiateInitialViewController()!,
        UIStoryboard.number2Storyboard.instantiateInitialViewController()!,
        UIStoryboard.number3Storyboard.instantiateInitialViewController()!,
        UIStoryboard.number4Storyboard.instantiateInitialViewController()!,
        UIStoryboard.number5Storyboard.instantiateInitialViewController()!,
        UIStoryboard.number6Storyboard.instantiateInitialViewController()!,
        UIStoryboard.number7Storyboard.instantiateInitialViewController()!
    ]
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    private var isFirstLayout = true
    private var disposeBag = Set<AnyCancellable>()
    private var currentPage: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage
            pageControl.currentPageIndicatorTintColor = Tag(rawValue: currentPage)?.backgroundColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayput()
        setupTag()
    }
    
    private func setupLayput() {
        tagBoaderView.backgroundColor = Tag.number1.backgroundColor
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageContainerView.addSubview(pageViewController.view)
        pageViewController.view.topAnchor.constraint(equalTo: pageContainerView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor).isActive = true
        pageViewController.view.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor).isActive = true
        pageViewController.setViewControllers([viewControllers.first!],
                                              direction: .forward,
                                              animated: false)
    }
    
    private func setupTag() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        Tag.allCases.forEach {
            let tagView = TagView(tag: $0)
            tagView.tagButtonPublisher.sink { [weak self] tagIndex in
                guard let self else {
                    return
                }
                if tagIndex > currentPage {
                    pageViewController.setViewControllers([viewControllers[tagIndex]],
                                                          direction: .forward,
                                                          animated: true)
                } else {
                    pageViewController.setViewControllers([viewControllers[tagIndex]],
                                                          direction: .reverse,
                                                          animated: true)
                }
                currentPage = tagIndex
                changeTag(at: tagIndex)
            }.store(in: &disposeBag)
            stackView.addArrangedSubview(tagView)
        }
        if isFirstLayout,
           let firstTag = stackView.arrangedSubviews.first as? TagView {
            firstTag.transform = CGAffineTransform(translationX: 0, y: Self.defaultTranslationY)
            isFirstLayout = false
        }
    }
    
    private func changeTag(at index: Int, for previousIndex: Int? = nil) {
        let targetTag = stackView.arrangedSubviews.compactMap {
            $0 as? TagView
        }[index]
        tagBoaderView.backgroundColor = Tag(rawValue: index)?.backgroundColor
        let dx = targetTag.center.x - scrollView.center.x
        let maxTravelAmount = scrollView.contentSize.width - scrollView.bounds.width
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else {
                return
            }
            let point = CGPoint(x: max(0, min(dx, maxTravelAmount)), y: 0)
            scrollView.contentOffset = point
            
            if let previousIndex,
               let previousTag = stackView.arrangedSubviews[previousIndex] as? TagView {
                previousTag.transform = .identity
            }
            targetTag.transform = CGAffineTransform(translationX: 0, y: Self.defaultTranslationY)
        }
    }
}

extension ViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let viewController = pageViewController.viewControllers?.first,
           let afterIndex = viewControllers.firstIndex(of: viewController),
           let previousViewController = previousViewControllers.first,
           let previousIndex = viewControllers.firstIndex(of: previousViewController) {
            changeTag(at: afterIndex, for: previousIndex)
            currentPage = afterIndex
        }
    }
}

extension ViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController),
           viewControllers.count - 1 > index {
            return viewControllers[index + 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController),
           0 < index {
            return viewControllers[index - 1]
        } else {
            return nil
        }
    }
}

