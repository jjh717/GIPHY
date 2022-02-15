//
//  GifObject.swift
//  GIPHY_SAMPLE
//
//  Created by Paul Jang on 2021/01/12.
//
 

struct Result: Codable, Equatable {
    let data: [GifObject]
}

struct GifObject: Codable, Equatable {
    let id: String?
    let images: Images?
}
 
struct Images: Codable, Equatable {
    let original: Original?
    let preview_gif: Thumbnail?
}

struct Original: Codable, Equatable {
    let width: String?
    let height: String?
    let url: String?
}

struct Thumbnail: Codable, Equatable {
    let width: String?
    let height: String?
    let url: String?    
} 
