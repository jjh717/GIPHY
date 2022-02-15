//
//  ImageDetailViewSectionModel.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import RxDataSources

struct GifSection {
    var header: String
    var items: [Item]
}

extension GifSection: SectionModelType {
    init(original: GifSection, items: [GifObject?]) {
        self = original
        self.items = items
    }
    
    typealias Item = GifObject?
}

 
