//
//  ViewController.swift
//  SeventeenTest
//
//  Created by Wei Kuo on 2021/2/24.
//

import UIKit
import SnapKit
import SDWebImage

class ViewController: UIViewController {
    let model = ViewModel()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let searchBar = UISearchBar(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.estimatedItemSize = .init(width: 90, height: 110)
            collectionViewLayout.minimumInteritemSpacing = 8
        }
        self.view.addSubview(self.collectionView)
        
        self.searchBar.delegate = self
        self.view.addSubview(self.searchBar)
        self.model.callback = self.collectionView.reloadData
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.snp.remakeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(collectionView.snp.top)
        }
        
        collectionView.snp.remakeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.dataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if let c = cell as? CollectionViewCell {
            if let user = model.getUser(userIndex: indexPath.item){
                c.nameLabel.text = user.login
                c.avatarImageView.sd_setImage(with: user.avatar_url, completed: nil)
            }
        }
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        collectionView.setContentOffset(.zero, animated: false)
        model.getSearchUser(keyword: searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            model.getSearchUser(keyword:nil)
        }
    }
}
