//
//  SetupProfileDevicesVC.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum SetupProfileExternalDevice:Int {
    case fitbit
    case appleWatch
}

extension SetupProfileExternalDevice {
    var title:String {
        switch self {
        case .fitbit:
            return "Fitbit"
        case .appleWatch:
            return "Apple Watch"
        }
    }

    var description:String {
        switch self {
        case .fitbit:
            return "Wearable device that tracks general health metrics"
        case .appleWatch:
            return "Wearable device that tracks general health metrics"
        }
    }

    var image: UIImage? {
        switch self {
        case .fitbit:
            return UIImage(named: "icon:  fitbit logo")
        case .appleWatch:
            return UIImage(named: "icon: apple watch")
        }
    }
}

fileprivate let devicesList: [SetupProfileExternalDevice] = [.fitbit, .appleWatch]

class SetupProfileDevicesVC: BaseProfileSetupViewController {
    // MARK: Outlets
    @IBOutlet weak var viewNavigationItem: UINavigationItem!

    lazy var devicesCollection: UICollectionView = {
        let devicesCollection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        devicesCollection.backgroundColor = .clear
        devicesCollection.showsVerticalScrollIndicator = false
        devicesCollection.delegate = self
        devicesCollection.dataSource = self
        devicesCollection.translatesAutoresizingMaskIntoConstraints = false
        return devicesCollection
    }()
    
    var fitbitModel: FitbitModel = FitbitModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(devicesCollection)

        devicesCollection.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        devicesCollection.delegate = self
        devicesCollection.dataSource = self
        checkIfDevicesAreConnectedAlready()
        self.addProgressbar(progress: 80.0)
        self.navigationController?.navigationBar.isTranslucent = false
        guard let deviceCollectionLayout = devicesCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        deviceCollectionLayout.minimumInteritemSpacing = 24
        deviceCollectionLayout.scrollDirection = .vertical
        deviceCollectionLayout.invalidateLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
    }

    func checkIfDevicesAreConnectedAlready() {
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) {
            [unowned self] in
            DispatchQueue.main.async {
                if let devices = AppSyncManager.instance.healthProfile.value?.devices {
                    if let fitbit = devices[ExternalDevices.fitbit],
                        let connected = fitbit["connected"],
                        connected == 1 {
                            self.devicesCollection.reloadItems(at: [IndexPath(row: 0, section: 0)])
                    } else {
                        self.devicesCollection.reloadItems(at: [IndexPath(row: 0, section: 0)])
                    }

                    if let watch = devices[ExternalDevices.watch],
                        let connected = watch["connected"],
                        connected == 1 {
                            self.devicesCollection.reloadItems(at: [IndexPath(row: 1, section: 0)])
                    } else {
                        self.devicesCollection.reloadItems(at: [IndexPath(row: 1, section: 0)])
                    }
                }
            }
        }
    }

    @objc
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        AppSyncManager.instance.healthProfile.remove(observer: self)
    }
}

extension SetupProfileDevicesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devicesList.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.getSupplementaryView(with: SetupProfileDevicesHeaderView.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? SetupProfileDevicesHeaderView else {preconditionFailure("Unexpected element Kind")}
            return header
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.getSupplementaryView(with: SetupProfileDevicesFooterView.self, viewForSupplementaryElementOfKind: kind, at: indexPath) as? SetupProfileDevicesFooterView else {preconditionFailure("Unexpected element Kind")}
            footer.delegate = self
            return footer
        default:
            preconditionFailure("Unexpected element Kind")
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getUniqueCell(with: SetupProfileDevicesConnectCell.self, at: indexPath) as? SetupProfileDevicesConnectCell else {preconditionFailure("invalid cell")}
        let device = devicesList[indexPath.row]
        cell.deviceEnum = device
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width
        return CGSize(width: width - 30, height: CGFloat(80))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.size.width
        return CGSize(width: width - 30, height: CGFloat(375))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let width = view.frame.size.width
        return CGSize(width: width - 30, height: CGFloat(100))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SetupProfileDevicesConnectCell else {
            return
        }
        
        if let device = cell.deviceEnum {
            switch device {
            case .fitbit:
                if let devices = AppSyncManager.instance.healthProfile.value?.devices,
                   let fitbit = devices[ExternalDevices.fitbit],
                   let connected = fitbit["connected"], connected == 1 {
                    AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 0)
                    fitbitModel.revokeToken()
                } else {
                    if let context = UIApplication.shared.keyWindow {
                        self.fitbitModel.contextProvider = AuthContextProvider(context)
                    }
                    self.fitbitModel.auth { [unowned self] authCode, error in
                        if error != nil {
                            print("Auth flow finished with error \(String(describing: error))")
                            AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 0)
                        } else {
                            guard let authCode = authCode else {return}
                            print("Your auth code is \(authCode)")
                            self.fitbitModel.token(authCode: authCode)
                            AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 1)
                        }
                    }
                }
            case .appleWatch:
                let applewatchViewController = AppleWatchConnectViewController()
                let navigationController = UINavigationController(rootViewController: applewatchViewController)
                NavigationUtility.presentOverCurrentContext(destination: navigationController)
            }
        }
    }
}

extension UIButton {
    func alignVertical(spacing: CGFloat = 6.0) {
        guard let imageSize = imageView?.image?.size,
              let text = titleLabel?.text,
              let font = titleLabel?.font
        else { return }

        titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: -imageSize.width,
            bottom: -(imageSize.height + spacing),
            right: 0.0
        )

        let titleSize = text.size(withAttributes: [.font: font])
        imageEdgeInsets = UIEdgeInsets(
            top: -(titleSize.height + spacing),
            left: 0.0,
            bottom: 0.0,
            right: -titleSize.width
        )

        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
        contentEdgeInsets = UIEdgeInsets(
            top: edgeOffset,
            left: 0.0,
            bottom: edgeOffset,
            right: 0.0
        )
    }
}

extension SetupProfileDevicesVC: SetupProfileDevicesFooterViewCellDelegate {
    func continueButton(wasPressedOnCell cell: SetupProfileDevicesFooterView) {
        let storyboard = UIStoryboard(name: "ProfileSetup", bundle: nil)
        guard let preconditionsViewController = storyboard.instantiateViewController(withIdentifier: "SetupProfilePreExistingConditionVC") as? SetupProfilePreConditionVC else { return }
        self.navigationController?.pushViewController(preconditionsViewController, animated: true)
    }
}
