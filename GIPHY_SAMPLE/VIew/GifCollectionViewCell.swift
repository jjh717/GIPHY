//
//  GifCollectionViewCell.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/13.
//

import UIKit
import Kingfisher
import RxSwift

class GifCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentImageView: UIImageView!
    
    var disposeBag = DisposeBag()
    
    func setData(model: GifObject) {
        if let urlStr = model.images?.preview_gif?.url, let url = URL(string: urlStr) {            
            contentImageView.kf.setImage(with: url)
        }
    }
    
    override func prepareForReuse() {
        contentImageView.image = nil
        contentImageView.kf.cancelDownloadTask()
        disposeBag = DisposeBag()
    }
}
