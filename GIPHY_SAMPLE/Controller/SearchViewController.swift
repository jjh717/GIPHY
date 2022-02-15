//
//  SearchViewController.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import Kingfisher
import RxDataSources
import RxGesture

class SearchViewController: UIViewController, StoryboardView {
    var disposeBag = DisposeBag()
    private var serviceProvider = ServiceProvider()
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var gifCollectionView: UICollectionView!
    
    @IBOutlet weak var typeBackground: UIView!
    @IBOutlet weak var gifTypeView: UIView!
    @IBOutlet weak var stickerTypeView: UIView!
    
    @IBOutlet weak var gifsLabel: UILabel!
    @IBOutlet weak var stickersLabel: UILabel!
    
    var selectView = UIView()
    
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
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "GIF 검색"
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reactor = SearchReactor(provider: serviceProvider)
        
        setupUI()
    }
    
    func setupUI() {
        initSearchBarSetting()
        initTypeView()
        
        if let layout = gifCollectionView.collectionViewLayout as? DynamicLayout {
            layout.delegate = self
        }
    }
    
    func initSearchBarSetting() {
        searchController.searchBar.setValue("취소", forKey:"cancelButtonText")
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.title = "검색"
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func initTypeView() {
        self.view.layoutIfNeeded()
        gifsTypeSelect(animation: false)
        
        selectView.layer.cornerRadius = 15
        selectView.backgroundColor = .systemPink
        typeBackground.addSubview(selectView)
    }
    
    func gifsTypeSelect(animation: Bool) {
        let margin: CGFloat = 10
        
        if animation {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.selectView.backgroundColor = .systemPink
                self.selectView.frame = CGRect(x: self.gifsLabel.frame.origin.x - (margin * 2), y: self.gifsLabel.frame.origin.y - margin,
                                               width: self.gifsLabel.frame.size.width + (margin * 4), height: self.gifsLabel.frame.size.height + (margin * 2))
            }
            return
        }
        
        selectView.frame = CGRect(x: gifsLabel.frame.origin.x - (margin * 2), y: gifsLabel.frame.origin.y - margin,
                                       width: gifsLabel.frame.size.width + (margin * 4), height: gifsLabel.frame.size.height + (margin * 2))
    }
    
    func stickerTypeSelect(animation: Bool) {
        let margin: CGFloat = 10
        
        if animation {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.selectView.backgroundColor = .systemBlue
                self.selectView.frame = CGRect(x: self.stickerTypeView.frame.origin.x + self.stickersLabel.frame.origin.x - (margin * 2), y: self.stickersLabel.frame.origin.y - margin,
                                               width: self.stickersLabel.frame.size.width + (margin * 4), height: self.stickersLabel.frame.size.height + (margin * 2))
            }
            return
        }
        
        selectView.frame = CGRect(x: stickersLabel.frame.origin.x - (margin * 2), y: stickersLabel.frame.origin.y - margin,
                                  width: stickersLabel.frame.size.width + (margin * 4), height: stickersLabel.frame.size.height + (margin * 2))
    }
     
    func bind(reactor: SearchReactor) {
        //에러, 상태 체크
        reactor.state.map { $0.error }
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] in
                print("error : ", $0)
            })
            .disposed(by: self.disposeBag)
        
        searchController.searchBar.rx.cancelButtonClicked
            .map { Reactor.Action.searchKeyword("") }
            .bind(to: reactor.action).disposed(by: disposeBag)

        searchController.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .filter {
                return $0 == "" ? false : true
            }            
            .map { Reactor.Action.searchKeyword($0) }
            .map { [weak self] in
                self?.gifCollectionView.contentOffset = CGPoint(x: 0, y: 0)
                return $0
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
 
        reactor.state.map { $0.gifObjs }
            .distinctUntilChanged()
            .filterNil()
            .map { (result) -> [GifSection] in                
                return [GifSection(header: "", items: result)]
            }
            .bind(to: gifCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
                
        reactor.state.map { $0.loadingViewIsHidden }.bind(to: loadIndicator.rx.isHidden).disposed(by: disposeBag)
 
        Observable.zip(gifCollectionView.rx.itemSelected, gifCollectionView.rx.modelSelected(GifObject.self))
            .bind {[weak self] indexPath, item in
                guard let self = self else { return }
                 
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
                    vc.reactor = DetailReactor(provider: self.serviceProvider, gifObj: item)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }.disposed(by: disposeBag)
        
        gifCollectionView.rx.willDisplayCell
            .bind(onNext: { [weak self] cell, indexPath in
                self?.reactor?.action.onNext(.checkLoadMoreData(indexPath.row))
            })
            .disposed(by: disposeBag)
 
        gifTypeView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.gifsTypeSelect(animation: true)
                self?.reactor?.action.onNext(.searchItemTypeChange(ItemType.GIF))
            })
            .disposed(by: disposeBag)

        stickerTypeView.rx.tapGesture().when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.stickerTypeSelect(animation: true)
                self?.reactor?.action.onNext(.searchItemTypeChange(ItemType.STICKER))
            })
            .disposed(by: disposeBag)
    }
}
 
extension SearchViewController: UICollectionViewDelegateFlowLayout, DynamicLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {

        if let obj = reactor?.currentState.gifObjs {
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

