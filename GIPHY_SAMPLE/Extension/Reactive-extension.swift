//
//  Reactive-extension.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import RxSwift
import RxCocoa

extension Reactive where Base : UIViewController {
    internal var viewWillAppear: Observable<[Any]> {
        return methodInvoked(#selector(UIViewController.viewWillAppear(_:)))
    }
    internal var viewWillDisappear: Observable<[Any]> {
        return methodInvoked(#selector(UIViewController.viewWillDisappear(_:)))
    }
    internal var viewDidLoad: Observable<[Any]> {
        return methodInvoked(#selector(UIViewController.viewDidLoad))
    }
    internal var viewDidAppear: Observable<[Any]> {
        return methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
    }
    internal var viewDidDisappear: Observable<[Any]> {
        return methodInvoked(#selector(UIViewController.viewDidDisappear(_:)))
    }
}

extension Observable {
    /// Returns an `Observable` where the nil values from the original `Observable` are skipped
    func unwrap<T>() -> Observable<T> where Element == T? {
        self.filter { $0 != nil }.map { $0! }
    }
}
