//
//  CheckinLogViewController.swift
//  Longevity
//
//  Created by vivek on 27/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckinLogViewController: BaseViewController {

    lazy var checkinLogTableView: UITableView = {
           let profileTable = UITableView(frame: CGRect.zero, style: .grouped)
           profileTable.backgroundColor = .clear
           profileTable.separatorStyle = .none
           profileTable.delegate = self
           profileTable.dataSource = self
           profileTable.translatesAutoresizingMaskIntoConstraints = false
           return profileTable
       }()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
    }

    init() {
        super.init(viewTab: .myData)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckinLogViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let headerView = tableView.getHeader(with: CheckinLogHeader.self, index: section) as? CheckinLogHeader else {
                preconditionFailure("Invalid header view")
            }
//            headerView.currentView = self.currentProfileView
//            headerView.delegate = self

            return headerView
        }
        guard let header = tableView.getHeader(with: UITableViewHeaderFooterView.self, index: section) else {
            preconditionFailure("Invalid header view")
        }

        header.backgroundColor = .clear

        let title = UILabel()
        title.text = "header"
        title.font = UIFont(name: "Montserrat-Medium", size: 14.0)
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.sizeToFit()
        title.translatesAutoresizingMaskIntoConstraints = false

        header.addSubview(title)

        NSLayoutConstraint.activate([
            title.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10.0)
        ])

        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.getCell(with: CheckinLogCell.self, at: indexPath) as? CheckinLogCell else {
            preconditionFailure("Invalid activity cell")
        }
        return cell
    }

}
