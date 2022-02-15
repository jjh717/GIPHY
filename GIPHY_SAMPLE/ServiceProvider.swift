//
//  ServiceProvider.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/15.
//

import Foundation

protocol ServiceProviderType: AnyObject {
    var gifRequest: GifRequestType { get }
    var databaseService: DatabaseService { get }
}

final class ServiceProvider: ServiceProviderType {
    lazy var gifRequest: GifRequestType = GifRequest()
    lazy var databaseService = DatabaseService()
}
