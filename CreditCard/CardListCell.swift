//
//  CardListCell.swift
//  CreditCard
//
//  Created by Terry on 2022/01/10.
//

import UIKit

class CardListCell: UITableViewCell {

    @IBOutlet var cardImageView: UIImageView!
    @IBOutlet var rankLabel: UILabel!
    @IBOutlet var promotionLabel: UILabel!
    @IBOutlet var cardNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
