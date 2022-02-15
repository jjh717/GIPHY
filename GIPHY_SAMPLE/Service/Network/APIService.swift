//
//  APIService.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import Foundation
import Alamofire
import RxSwift
 
protocol APIServiceProtocol {
    func fetch<T: Codable>(request: UserEndpoint) -> Observable<T>
}

class APIService: APIServiceProtocol {
    func fetch<T: Codable>(request: UserEndpoint) -> Observable<T> {
        return Observable.create { observer -> Disposable in
            AF.request(request).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let model: T = try JSONDecoder().decode(T.self, from: data )
                        observer.onNext(model)
                        
                    } catch let error {
                        observer.onError(error)
                    }
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}

//
//class APIService {
//    static func searchGIF(keyword: String?, page: Int, itemType: ItemType) -> Observable<(obj: [GifObject], nextPage: Int?)> {
//        guard let query = keyword, keyword != "" else {
//            print("keyword empty")
//            return .just(([], 0))
//        }
//
//        var request = UserEndpoint.searchGIF(keyword: query, page: page)
//        if itemType == ItemType.STICKER {
//            request = UserEndpoint.searchSTICKER(keyword: query, page: page)
//        }
//
//        return Observable.create { observer -> Disposable in
//            AF.request(request).responseJSON { response in
//                switch response.result {
//                case .success(let value):
//                    if let result = JSON(value)["data"].rawString(), let gifObj = Mapper<GifObject>().mapArray(JSONString: result) {
//                        let nextPage = page + 1
//                        observer.onNext((gifObj, nextPage))
//                    }
//
//                    observer.onCompleted()
//
//                case .failure(let error):
//                    observer.onError(error)
//                }
//            }
//
//            return Disposables.create()
//        }
//    }
//}
