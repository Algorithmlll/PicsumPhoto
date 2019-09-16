//
//  PhotoCollectionViewCell.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 16/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageview: UIImageView!
    
    static let identifier = "PhotoCollectionViewCell"
    var representedAssetIdentifier: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            imageview.image = thumbnailImage
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageview.image = nil
    }

}
