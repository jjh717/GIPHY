//
//  DetailReactor.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/15.
//

import Foundation
import ReactorKit
import RxCocoa
import RxSwift

class DetailReactor: Reactor {
    let initialState: State
      
    let provider: ServiceProviderType
    
    enum Action {
        case favoriteCheck
    }
    
    enum Mutation {
        case setFavoriteCheck(Bool)
    }
    
    struct State {
        var gifObj: GifObject?
        var favoriteDict = [String : GifObject]()
        var isFavorite = false
    }
    
    init(provider: ServiceProviderType, gifObj: GifObject) {
        self.provider = provider
        
        let isFavorite = provider.databaseService.findFavoriteItem(id: gifObj.id)
        self.initialState = State(gifObj: gifObj, isFavorite: isFavorite)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .favoriteCheck:
            if currentState.isFavorite {
                provider.databaseService.deleteFavoriteItem(id: currentState.gifObj?.id)
                return .just(Mutation.setFavoriteCheck(false))
            } else {
                provider.databaseService.addFavoriteList(obj: currentState.gifObj)
                return .just(Mutation.setFavoriteCheck(true))
            } 
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFavoriteCheck(let result):
            newState.isFavorite = result
        }
        return newState
    }
     
}
 
