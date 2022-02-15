//
//  FavoriteReactor.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/15.
//

import Foundation
import ReactorKit
import RxCocoa
import RxSwift

class FavoriteReactor: Reactor {
    let initialState: State
      
    let provider: ServiceProviderType
    
    enum Action {
        case loadFavoriteList
    }
     
    enum Mutation {
        case setFavoriteList([GifObject])
    }
    
    struct State {
        var favoriteList = [GifObject]()
    }
    
    init(provider: ServiceProviderType) {
        self.provider = provider
                
        self.initialState = State(favoriteList: provider.databaseService.getFavoriteList())
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadFavoriteList:
            return .just(Mutation.setFavoriteList(provider.databaseService.getFavoriteList()))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFavoriteList(let list):
            newState.favoriteList = list
        }
        return newState
    }
     
}
 
