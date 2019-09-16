//
//  Constants.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 12/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import Foundation

struct Const {
    struct ServerURL {
        static let baseURL = "https://picsum.photos/v2"
    }
    
    struct APIParameterKey {
        static let page         = "page"
        static let limit        = "limit"
    }
    
    enum HTTPHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
    }
    
    enum ContentType: String {
        case json = "application/json"
    }
}


enum DisplayPhoto: String {
    case cache
    case asset
}
