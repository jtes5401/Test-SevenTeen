//
//  CollectionViewCell.swift
//  SeventeenTest
//
//  Created by Wei Kuo on 2021/2/25.
//

import UIKit
import SnapKit

class CollectionViewCell: UICollectionViewCell {
    var nameLabel = UILabel(frame: .zero)
    var avatarImageView = UIImageView(frame: .zero)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(avatarImageView)
        nameLabel.textAlignment = .center

        avatarImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(90)
            make.width.equalTo(90)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(90)
            make.top.equalTo(avatarImageView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
