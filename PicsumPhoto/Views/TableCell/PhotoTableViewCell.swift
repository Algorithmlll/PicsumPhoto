//
//  PhotoTableViewCell.swift
//  PicsumPhoto
//
//  Created by Same Chinnawat on 13/9/2562 BE.
//  Copyright © 2562 Same Chinnawat. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoTableViewCell: UITableViewCell {
    
    static let identifier = "PhotoTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyTheme()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK:- Apply Theme
    func applyTheme() {
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
    
}
