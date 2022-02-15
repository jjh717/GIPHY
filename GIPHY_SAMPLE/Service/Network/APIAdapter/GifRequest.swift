//
//  GifRequest.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/13.
//
 
import RxSwift

protocol GifRequestType {
    func searchGIF(keyword: String, page: Int, limit: Int) -> Observable<(Result)>
    func searchSTICKER(keyword: String, page: Int, limit: Int) -> Observable<(Result)>
}
 
class GifRequest: APIService, GifRequestType {
    func searchGIF(keyword: String, page: Int, limit: Int) -> Observable<(Result)> {
        return fetch(request: UserEndpoint.searchGIF(keyword: keyword, page: page, limit: limit))
    }
    
    func searchSTICKER(keyword: String, page: Int, limit: Int) -> Observable<(Result)> {
        return fetch(request: UserEndpoint.searchSTICKER(keyword: keyword, page: page, limit: limit))
    }
}
