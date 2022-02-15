//
//  DetailViewController.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/15.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import Kingfisher

class DetailViewController: UIViewController, StoryboardView {
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var contentImageView: UIImageView!
     
    func bind(reactor: DetailReactor) {
        reactor.state.map { $0.gifObj }
            .distinctUntilChanged()
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] in
               if let urlStr = $0.images?.original?.url, let url = URL(string: urlStr) {
                   
                   self?.contentImageView.kf.setImage(with: url, completionHandler: { _ in
                       self?.loadIndicator.isHidden = true
                   })
               }
            }.disposed(by: disposeBag)
         
        favoriteButton.rx.tap
            .map { Reactor.Action.favoriteCheck }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)

        reactor.state.map { $0.isFavorite }
            .subscribe(onNext: { [weak self] in
                if $0 == true {
                    self?.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                } else {
                    self?.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                }
            })
            .disposed(by: self.disposeBag)
    }
}

