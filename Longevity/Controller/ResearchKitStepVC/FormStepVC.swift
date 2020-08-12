//
//  FormStepVC.swift
//  Longevity
//
//  Created by vivek on 11/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit

class FormStepVC: ORKStepViewController {
    lazy var formItemsCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        return collection
    }()

    let footerView:UIView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = .white
        return uiView
    }()

    let continueButton: CustomButtonFill = {
        let buttonView = CustomButtonFill()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.setTitle("Next", for: .normal)
        return buttonView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        presentViews()
    }

    func presentViews() {
        self.view.addSubview(formItemsCollection)
        self.view.addSubview(footerView)
        footerView.addSubview(continueButton)
        let footerViewHeight = CGFloat(130)

        NSLayoutConstraint.activate([
            formItemsCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            formItemsCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            formItemsCollection.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30),
            formItemsCollection.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                                             constant: -footerViewHeight)
        ])

        footerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        footerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: footerViewHeight).isActive = true

        continueButton.leftAnchor.constraint(equalTo: footerView.leftAnchor, constant: 15).isActive = true
        continueButton.rightAnchor.constraint(equalTo: footerView.rightAnchor, constant: -15).isActive = true
        continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 24).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        continueButton.isEnabled = true
        continueButton.addTarget(self, action: #selector(handleContinue(sender:)), for: .touchUpInside)

        guard let layout = formItemsCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 20.0
    }

    @objc func handleContinue(sender: UIButton) {
        self.goForward()
    }

}

extension FormStepVC: UICollectionViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let formStep = self.step as? ORKFormStep else {
            return 0
        }
        if formStep.formItems != nil {
            return formStep.formItems!.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let defaultCell = collectionView.getCell(with: UICollectionViewCell.self, at: indexPath)
        guard let formStep = self.step as? ORKFormStep else {
            return defaultCell
        }
        guard formStep.formItems != nil else {
            return defaultCell
        }
        let item = formStep.formItems![indexPath.item] as ORKFormItem

        if item.identifier == "" {
            let sectionItemCell = collectionView.getCell(with: RKCFormSectionItemView.self, at: indexPath) as! RKCFormSectionItemView
            sectionItemCell.createLayout(heading: item.text!)
            return sectionItemCell
        }

        let itemCell = collectionView.getCell(with: RKCFormItemView.self, at: indexPath) as! RKCFormItemView
        itemCell.createLayout(identifier:item.identifier, question: item.text!, answerFormat: item.answerFormat!)
        return itemCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat(50)
        let width = self.view.bounds.width
        return CGSize(width: width - CGFloat(40), height: height)
    }
}
