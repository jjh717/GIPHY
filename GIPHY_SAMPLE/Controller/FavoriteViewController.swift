//
//  FavoriteViewController.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/17.
//

import UIKit
import RxCocoa
import RxSwift 
import ReactorKit
import RxDataSources

class FavoriteViewController: UIViewController, StoryboardView {
    var disposeBag = DisposeBag()
    private var serviceProvider = ServiceProvider()
    @IBOutlet weak var gifCollectionView: UICollectionView!

    private let dataSource = RxCollectionViewSectionedReloadDataSource<GifSection>(
        configureCell: { (dataSource, collectionView, indexPath, item) in
            
            if let item = item {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GifCollectionViewCell.self), for: indexPath) as? GifCollectionViewCell else { return UICollectionViewCell() }
                cell.setData(model: item)
                return cell
            } else {
                return UICollectionViewCell()
            }
        }
    )
    
     override func viewDidLoad() {
        super.viewDidLoad()

        self.reactor = FavoriteReactor(provider: serviceProvider)
         
        setupUI()
    }

    func setupUI() {
        if let layout = gifCollectionView.collectionViewLayout as? DynamicLayout {
            layout.delegate = self
        }
    }

    func bind(reactor: FavoriteReactor) {
        rx.viewWillAppear.asObservable()
            .subscribe { [weak self] _ in
                self?.reactor?.action.onNext(.loadFavoriteList)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.favoriteList }
            .map { (result) -> [GifSection] in
                return [GifSection(header: "", items: result)]
            }
            .bind(to: gifCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        Observable.zip(gifCollectionView.rx.itemSelected, gifCollectionView.rx.modelSelected(GifObject.self))
            .bind {[weak self] indexPath, item in
                guard let self = self else { return }
                 
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                    vc.reactor = DetailReactor(provider: self.serviceProvider, gifObj: item)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }.disposed(by: disposeBag)
    }
}
  
extension FavoriteViewController: UICollectionViewDelegateFlowLayout, DynamicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        if let obj = reactor?.currentState.favoriteList {
            guard obj.count > indexPath.row else {
                print("obj.count < indexPath.row")
                return 0
            }

            if let strHeight = obj[safe: indexPath.row]?.images?.preview_gif?.height, let _height = Float(strHeight),
               let strWidth = obj[safe: indexPath.row]?.images?.preview_gif?.width, let _width = Float(strWidth){
                return CGFloat(_height) * CGFloat(width) / CGFloat(_width)
            }
        }

        return 0
    }
}
