//
//  SCPageViewController.swift
//  TabBar
//
//  Created by Mariam on 5/22/20.
//  Copyright © 2020 Mariam. All rights reserved.
//

import UIKit

protocol SCPageViewControllerTransitionDelegate: class {
    func pageViewController(_ pageViewController: SCPageViewController, didScrollTo index: Int)
}

class SCPageViewController: UIPageViewController {

    //MARK:- Properties
    private lazy var presentingViewControllers: [UIViewController] = []
    weak var transitionDelegate: SCPageViewControllerTransitionDelegate?

    //MARK:- Overided functions
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
    }
    
    init(presentingViewControllers: [UIViewController]) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        setPresentingViewControllers(presentingViewControllers)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    //MARK:- Public Functions
    func setPresentingViewControllers(_ controllers: [UIViewController]) {
        presentingViewControllers = controllers
        if let firstViewController = presentingViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    func selectPage(at index: Int, update: Bool = true) {
        if index >= presentingViewControllers.count { return }
        
        guard let currentViewController = self.viewControllers?.first else { return }
        guard let currentIndex = presentingViewControllers.firstIndex(of: currentViewController) else { return }
       
        if currentIndex == index { return }

        var viewController: UIViewController!
        var direction: UIPageViewController.NavigationDirection!
        
        if index > currentIndex {
            let nextViewController = presentingViewControllers[index]
            viewController = nextViewController
            direction = .forward
        } else if index < currentIndex {
            let previousViewController = presentingViewControllers[index]
            viewController = previousViewController
            direction = .reverse
        }

        setViewControllers([viewController], direction: direction, animated: true, completion:{ completed in self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: update ? completed: false) })
    }
    
    func selectNext() -> Int {
        guard let currentViewController = self.viewControllers?.first else { return 0 }
        guard let currentIndex = presentingViewControllers.firstIndex(of: currentViewController) else { return 0 }
        let index = currentIndex + 1
        if index >= presentingViewControllers.count { return -1 }
        var viewController: UIViewController!
        var direction: UIPageViewController.NavigationDirection!
        let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController)
        viewController = nextViewController
        direction = .forward
        setViewControllers([viewController], direction: direction, animated: true, completion:{ completed in self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: false) })
        return index
    }

}

//MARK:- UIPageViewControllerDataSource
extension SCPageViewController: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return presentingViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = presentingViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard presentingViewControllers.count > previousIndex else {
            return nil
        }
        
        return presentingViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = presentingViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = presentingViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return presentingViewControllers[nextIndex]
    }
}

extension SCPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        
        if let presentingViewController = pageViewController.viewControllers?.first, let viewControllerIndex = presentingViewControllers.firstIndex(of: presentingViewController) {
            transitionDelegate?.pageViewController(self, didScrollTo: viewControllerIndex)
        }
    }
}
