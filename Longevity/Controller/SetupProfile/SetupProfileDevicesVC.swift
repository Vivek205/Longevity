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

    var fitbitModel: FitbitModel = FitbitModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        collectionView.delegate = self
        collectionView.dataSource = self
        checkIfDevicesAreConnectedAlready()
    }

    func checkIfDevicesAreConnectedAlready() {
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) {
            [weak self] in
            if let devices = AppSyncManager.instance.healthProfile.value?.devices {
                if let fitbit = devices[ExternalDevices.fitbit] {
                    DispatchQueue.main.async {
                        setupProfileConnectDeviceOptionList[2]?.isConnected = fitbit["connected"] == 1
                        self?.collectionView.reloadData()
                    }
                }
            }
        }

    }

    // MARK: Actions
    @IBAction func handleContinue(_ sender: Any) {
        performSegue(withIdentifier: "SetupProfileDevicesToPreExistingConditions", sender: self)
    }
}

extension SetupProfileDevicesVC: SetupProfileDevicesConnectCellDelegate {
    func connectBtn(wasPressedOnCell cell: SetupProfileDevicesConnectCell) {
        switch cell.titleLabel.text {
        case "Fitbit":
            print("connected fitbit data")
            if let context = UIApplication.shared.keyWindow {
                fitbitModel.contextProvider = AuthContextProvider(context)
            }
            fitbitModel.auth { authCode, error in
                if error != nil {
                    print("Auth flow finished with error \(String(describing: error))")
                    AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 0)
                } else {
                    print("Your auth code is \(String(describing: authCode))")
                    self.fitbitModel.token(authCode: authCode!)
                    AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 1)
                    DispatchQueue.main.async {
                        setupProfileConnectDeviceOptionList[2]?.isConnected = true
                        self.collectionView.reloadData()
                    }
                }
            }
        default:
            HealthStore.shared.getHealthKitAuthorization { (authorized) in
                if authorized {
                    AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.healthkit, connected: 1)
                } else {
                    AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.healthkit, connected: 0)
                }
            }
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
            if option?.isConnected == true {
                cell.connectBtn.setTitle("SYNCED", for: .normal)
                cell.connectBtn.setTitleColor(#colorLiteral(red: 0.3529411765, green: 0.6549019608, blue: 0.6549019608, alpha: 1), for: .normal)
                cell.connectBtn.setImage(#imageLiteral(resourceName: "icon: check mark"), for: .normal)
            } else {
                let image = UIImage(named: "")
                cell.connectBtn.setTitle(nil, for: .normal)
                cell.connectBtn.setImage(#imageLiteral(resourceName: "icon: add"), for: .normal)
            }

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
