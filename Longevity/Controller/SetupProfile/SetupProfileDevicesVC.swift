//
//  SetupProfileDevicesVC.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SetupProfileDevicesVC: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

extension SetupProfileDevicesVC: SetupProfileDevicesConnectCellDelegate {
    func connectBtn(wasPressedOnCell cell: SetupProfileDevicesConnectCell) {
        switch cell.titleLabel.text {
        case "Fitbit":
            print("connected fitbit data")
            guard let fitbiturl = URL(string: "https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=22BN4J&redirect_uri=http%3A%2F%2Flocalhost&scope=activity%20nutrition%20heartrate%20location%20nutrition%20profile%20settings%20sleep%20social%20weight") else { return }
            UIApplication.shared.open(fitbiturl)
        default:
            print(cell.titleLabel.text)
        }
    }
}

extension SetupProfileDevicesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileDevicesImageCell", for: indexPath)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileDevicesInfoCell", for: indexPath)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileDevicesConnectCell", for: indexPath) as! SetupProfileDevicesConnectCell
            let option = setupProfileConnectDeviceOptionList[indexPath.row]
            cell.image.image = option?.image
            cell.titleLabel.text = option?.title
            cell.descriptionLabel.text = option?.description
            cell.contentContainerView.layer.cornerRadius = 4
            cell.contentContainerView.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            cell.layer.shadowRadius = 2.0
            cell.layer.shadowOpacity = 0.14
            cell.layer.masksToBounds = false
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.size.height
        let width = view.frame.size.width
        switch indexPath.row {
        case 0:
            return CGSize(width: width - 40, height: CGFloat(270))
        case 1:
            return CGSize(width: width - 40, height: CGFloat(150))
        default:
            return CGSize(width: width - 40, height: CGFloat(80))
        }
    }
}
