//
//  CheckinLogViewController.swift
//  Longevity
//
//  Created by vivek on 27/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogViewController: BaseViewController {

    lazy var logsCollectionView: UICollectionView = {
        let logsCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        logsCollection.backgroundColor = .clear
        logsCollection.showsVerticalScrollIndicator = false
        logsCollection.delegate = self
        logsCollection.dataSource = self
        logsCollection.translatesAutoresizingMaskIntoConstraints = false
        return logsCollection
    }()
    
    lazy var closeButton: UIButton = {
        let close = UIButton()
        close.setImage(UIImage(named: "closex")?.withRenderingMode(.alwaysTemplate), for: .normal)
        close.setImage(UIImage(named: "closex")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        close.tintColor = .white
        close.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        close.translatesAutoresizingMaskIntoConstraints = false
        return close
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleView.titleLabel.text = "Check-in Log"
        
        self.view.addSubview(logsCollectionView)
        self.titleView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            logsCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            logsCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            logsCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            logsCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 30.0),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor),
            closeButton.leadingAnchor.constraint(equalTo: self.titleView.leadingAnchor, constant: 20.0),
            closeButton.centerYAnchor.constraint(equalTo: self.titleView.titleLabel.centerYAnchor)
        ])
        
        guard let layout = logsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.sectionInset = UIEdgeInsets(top: 20.0, left: 15.0, bottom: 20.0, right: 15.0)
        layout.minimumInteritemSpacing = 18
        layout.scrollDirection = .vertical
    }

    init() {
        super.init(viewTab: .myData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CheckinLogViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.getSupplementaryView(with: CheckinLogHeader.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? CheckinLogHeader else {
            preconditionFailure("Invalid header")
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 150.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: CheckinLogCell.self, at: indexPath) as? CheckinLogCell else {
            preconditionFailure("Invalid log cell type")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 30.0
        return CGSize(width: width, height: 92.0)
    }
}
