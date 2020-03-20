//
//  IssueCell.swift
//  Json
//
//  Created by Mayank Gupta on 20/03/20.
//  Copyright © 2020 Archidev. All rights reserved.
//

import UIKit

class IssueCell: UITableViewCell {

    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var issueLbl: UILabel!
    @IBOutlet var avatarView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

   
}
