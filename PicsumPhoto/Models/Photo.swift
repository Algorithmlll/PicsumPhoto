//
//  Photo.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 12/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import Foundation

struct Photo: Codable {
    var id: String
    var author: String
    var width: Int
    var height: Int
    var url: URL
    var download_url: URL
}


