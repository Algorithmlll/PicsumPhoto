//
//  Alamofire+extension.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 12/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import UIKit
import Foundation

let gifData: Data = {
    let url = Bundle.main.url(forResource: "running-loading", withExtension: "gif")!
    return try! Data(contentsOf: url)
}()
