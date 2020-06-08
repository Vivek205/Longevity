//
//  SwipingVC.swift
//  Longevity
//
//  Created by vivek on 08/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SwipingVC: UIViewController {
    @IBOutlet weak var pageCollectionView: UICollectionView!

}

extension SwipingVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = pageCollectionView.dequeueReusableCell(withReuseIdentifier: "onboardingCollectionCell", for: indexPath) as? OnboardingCollectionViewCell
        cell?.number?.text = String(indexPath.row)
        return cell!
    }


}
