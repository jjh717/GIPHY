//
//  SearchReactor.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//

import ReactorKit
import RxSwift
import RxOptional

enum ItemType {
    case GIF
    case STICKER
}

class SearchReactor: Reactor {
    let initialState: State
    let provider: ServiceProviderType
    
    init(provider: ServiceProviderType) {
        self.provider = ServiceProvider()
        
        initialState = State()
    }
    
    enum Action {
        case searchKeyword(String)
        case checkLoadMoreData(Int)
        case searchItemTypeChange(ItemType)
    }
    
    enum Mutation {
        case setKeyword(String)
        case setGifObj([GifObject])
        case setPageNumber(Int)
        case setIsDataLoading(Bool)
        case setSearchItemType(ItemType)
                
        case setError(Error)
    }
    
    struct State {
        var keyword = ""
        var searchType = ItemType.GIF
        
        var gifObjs: [GifObject]?
        var isDataLoading = false
        var loadingViewIsHidden: Bool = true
        
        var currentPage = 1
        var per_page = 20 //이미지 N 개씩 호출
        
        var error: Error?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            case let .searchKeyword(keyword):
                guard keyword != "" else {
                    return Observable.concat([
                        Observable.just(Mutation.setKeyword("")),
                        Observable.just(Mutation.setGifObj([]))
                    ])}
                         
                return Observable.concat([
                    Observable.just(Mutation.setKeyword(keyword)),                    
                    searchItem(keyword: keyword, searchType: currentState.searchType)
                ])
            
            case .checkLoadMoreData(let index):
                let currentItemCount = currentState.gifObjs?.count ?? 0
                if !currentState.isDataLoading, index > 0,
                   index > currentItemCount - currentState.per_page / 2 {
                    return Observable.concat([
                        Observable.just(Mutation.setPageNumber(currentState.currentPage + 1)),
                        searchItem(keyword: currentState.keyword, searchType: currentState.searchType)
                    ])
                }
            
                return Observable.empty()
            case .searchItemTypeChange(let itemType):
                if self.currentState.keyword != "" {
                                
                    var searchItemTypeObs: Observable<SearchReactor.Mutation>?
                    if itemType == ItemType.GIF {
                        searchItemTypeObs =  Observable.just(Mutation.setSearchItemType(ItemType.GIF))
                    } else {
                        searchItemTypeObs =  Observable.just(Mutation.setSearchItemType(ItemType.STICKER))
                    }
                    
                    guard let searchItemTypeObservable = searchItemTypeObs else { return Observable.empty() }
                    
                    return Observable.concat([
                        Observable.just(Mutation.setGifObj([])),
                        searchItemTypeObservable,
                        searchItem(keyword: currentState.keyword, searchType: itemType)
                    ])
                } else {
                    if itemType == ItemType.GIF {
                        return Observable.just(Mutation.setSearchItemType(ItemType.GIF))
                    } else {
                        return Observable.just(Mutation.setSearchItemType(ItemType.STICKER))
                    }
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            case let .setGifObj(obj):
                if newState.gifObjs == nil || obj.isEmpty {
                    newState.gifObjs = obj
                } else {
                    newState.gifObjs?.append(contentsOf: obj)
                }
            case let .setKeyword(keyword):
                newState.keyword = keyword
            case let .setIsDataLoading(isLoading):
                newState.isDataLoading = isLoading
                newState.loadingViewIsHidden = !isLoading
            case let .setSearchItemType(type):
                newState.searchType = type
            case .setPageNumber(let index):
                newState.currentPage = index
            case .setError(let error):
                newState.error = error
            
        }
        return newState
    }
    
    private func searchItem(keyword: String, searchType: ItemType) -> Observable<Mutation> {
        guard !currentState.isDataLoading else { return Observable.empty() }
         
        let request: Observable<SearchReactor.Mutation>?
        if searchType == .GIF {
            request = provider.gifRequest.searchGIF(keyword: keyword, page: currentState.currentPage, limit: currentState.per_page)
                    .map { Mutation.setGifObj($0.data) }
                    .catch { return .just(Mutation.setError($0)) }
        } else {
            request = provider.gifRequest.searchSTICKER(keyword: keyword, page: currentState.currentPage, limit: currentState.per_page)
                .map { Mutation.setGifObj($0.data) }
                    .catch { return .just(Mutation.setError($0)) }
        }
        
        if let request = request {
            return  Observable.concat([
                Observable.just(Mutation.setIsDataLoading(true)),
                request,
                Observable.just(Mutation.setIsDataLoading(false))
            ])
        } else {
            return .empty()
        }
    }
}
 
