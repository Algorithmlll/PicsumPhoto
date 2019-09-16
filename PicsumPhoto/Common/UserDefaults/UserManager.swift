//
//  UserManager.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 16/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import Foundation

enum UserDefaultsKey: String {
    case photoDownload = "PHOTO_DOWNLOAD"
}

struct UserManager {
    
    static var userDefaults: UserDefaults { return UserDefaults.standard }
    
    func setPhotoDownload(value: [String]) {
        UserManager.userDefaults.set(value, forKey: UserDefaultsKey.photoDownload.rawValue)
        UserManager.userDefaults.synchronize()
    }
    
    func getPhotoDownload() -> [String]? {
        return UserManager.userDefaults.array(forKey: UserDefaultsKey.photoDownload.rawValue) as? [String] ?? [String]()
    }
    
    
    func clearPhotoDownload() {
        UserManager.userDefaults.removeObject(forKey: UserDefaultsKey.photoDownload.rawValue)
        UserManager.userDefaults.synchronize()
    }
    
}
