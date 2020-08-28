//
//  CheckInLogDetailsViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 28/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInLogDetailsViewController: UIViewController {
    
    var history: History! {
        didSet {
            self.logDetailsTableView.reloadData()
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            if let date = dateformatter.date(from: history.recordDate) {
                dateformatter.dateFormat = "MMM dd, yyyy"
                self.logDate.text = dateformatter.string(from: date)
            }
        }
    }
    
    lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    
    lazy var bezelView: UIView = {
        let bezelview = UIView()
        bezelview.backgroundColor = UIColor(hexString: "#C7C7CC")
        bezelview.translatesAutoresizingMaskIntoConstraints = false
        bezelview.layer.cornerRadius = 1.0
        bezelview.layer.masksToBounds = true
        return bezelview
    }()
    
    lazy var logDate: UILabel = {
        let date = UILabel()
        date.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
        date.textColor = UIColor(hexString: "#4E4E4E")
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    
    lazy var exportButton: UIButton = {
        let export = UIButton()
        export.setTitle("Export", for: .normal)
        export.setTitleColor(.themeColor, for: .normal)
        export.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 18.0)
        export.backgroundColor = .clear
        export.translatesAutoresizingMaskIntoConstraints = false
        export.layer.borderWidth = 2
        export.layer.borderColor = UIColor.themeColor.cgColor
        export.layer.cornerRadius = 10.0
        export.addTarget(self, action: #selector(handleExportData), for: .touchUpInside)
        return export
    }()
    
    lazy var logDetailsTableView: UITableView = {
        let logdetailsTable = UITableView(frame: CGRect.zero, style: .plain)
        logdetailsTable.allowsSelection = false
        logdetailsTable.separatorStyle = .none
        logdetailsTable.delegate = self
        logdetailsTable.dataSource = self
        logdetailsTable.backgroundColor = .white
        logdetailsTable.translatesAutoresizingMaskIntoConstraints = false
        return logdetailsTable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        self.view.addSubview(containerView)
        self.containerView.addSubview(bezelView)
        self.containerView.addSubview(logDate)
        self.containerView.addSubview(exportButton)
        self.containerView.addSubview(logDetailsTableView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.view.centerYAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bezelView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 13.0),
            bezelView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bezelView.heightAnchor.constraint(equalToConstant: 2.0),
            bezelView.widthAnchor.constraint(equalToConstant: 30.0),
            logDate.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25.0),
            logDate.topAnchor.constraint(equalTo: bezelView.bottomAnchor, constant: 14.5),
            exportButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25.0),
            exportButton.centerYAnchor.constraint(equalTo: logDate.centerYAnchor),
            exportButton.widthAnchor.constraint(equalToConstant: 110.0),
            exportButton.heightAnchor.constraint(equalToConstant: 32.0),
            exportButton.leadingAnchor.constraint(greaterThanOrEqualTo: logDate.trailingAnchor, constant: 10.0),
            logDetailsTableView.topAnchor.constraint(equalTo: exportButton.bottomAnchor, constant: 25.0),
            logDetailsTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15.0),
            logDetailsTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15.0),
            logDetailsTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        tapgesture.numberOfTouchesRequired = 1
        
        self.view.addGestureRecognizer(tapgesture)
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func handleExportData() {
        let userInsightAPI = UserInsightsAPI()
        self.showSpinner()
        userInsightAPI.exportUserApplicationData(completion: {
            DispatchQueue.main.async {
                self.showAlert(title: "Success", message: "Your data has been sent to your email.")
                self.removeSpinner()
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.removeSpinner()
                self.showAlert(title: "Failure", message: "Unable to export your data. Please try again later.")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.containerView.layer.cornerRadius = 20.0
        self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.containerView.layer.masksToBounds = true
    }
}

extension CheckInLogDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return  history.symptoms.count
        } else if section == 1 {
            return history.insights.count
        } else {
            return history.goals.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.getCell(with: UITableViewCell.self, at: indexPath)
            cell.backgroundColor = .white
            
            let symptomLabel = UILabel()
            symptomLabel.text = history.symptoms[indexPath.row]
            symptomLabel.font = UIFont(name: "Montserrat-Regular", size: 18.0)
            symptomLabel.textColor = UIColor(hexString: "#4E4E4E")
            symptomLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let checkImage = UIImageView()
            checkImage.image = UIImage(named: "icon: checkbox-selected")
            checkImage.contentMode = .scaleAspectFit
            checkImage.translatesAutoresizingMaskIntoConstraints = false
            
            cell.addSubview(symptomLabel)
            cell.addSubview(checkImage)
            NSLayoutConstraint.activate([
                symptomLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 14.0),
                symptomLabel.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                checkImage.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -14.0),
                checkImage.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                checkImage.widthAnchor.constraint(equalToConstant: 24.0),
                checkImage.heightAnchor.constraint(equalTo: checkImage.widthAnchor)
            ])
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.getCell(with: UITableViewCell.self, at: indexPath)
            let insightsLabel = UILabel()
            insightsLabel.numberOfLines = 0
            insightsLabel.lineBreakMode = .byWordWrapping
            insightsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let insightTitle = history.insights[indexPath.row].text
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedinsightTitle = NSMutableAttributedString(string: insightTitle, attributes: attributes)
            
            let insightDesc = "\n\n\(history.insights[indexPath.row].goalDescription)"
            
            let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedDescText = NSMutableAttributedString(string: insightDesc, attributes: descAttributes)
            
            attributedinsightTitle.append(attributedDescText)
            insightsLabel.attributedText = attributedinsightTitle
            cell.addSubview(insightsLabel)
            
            NSLayoutConstraint.activate([
                insightsLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 14.0),
                insightsLabel.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 14.0),
                insightsLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -14.0),
                insightsLabel.bottomAnchor.constraint(lessThanOrEqualTo: cell.bottomAnchor, constant: -14.0)
            ])
            return cell
        } else {
        let cell = tableView.getCell(with: UITableViewCell.self, at: indexPath)
            
            let divider = UIView()
            divider.translatesAutoresizingMaskIntoConstraints = false
            divider.backgroundColor = UIColor(hexString: "#CECECE")
            
            let goalsView = UIView()
            goalsView.backgroundColor = .themeColor
            goalsView.translatesAutoresizingMaskIntoConstraints = false
            goalsView.layer.cornerRadius = 12.0
            goalsView.layer.masksToBounds = true

            let rowIndex = UILabel()
            rowIndex.font = UIFont(name: "Montserrat-SemiBold", size: 14.0)
            rowIndex.textColor = .white
            rowIndex.text = "\(indexPath.row + 1)"
            rowIndex.textAlignment = .center
            rowIndex.translatesAutoresizingMaskIntoConstraints = false
        
            let goalsLabel = UILabel()
            goalsLabel.numberOfLines = 0
            goalsLabel.lineBreakMode = .byWordWrapping
            goalsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let goalTitle = history.goals[indexPath.row].text
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 17.0),.foregroundColor: UIColor.black]
            let attributedInfoText = NSMutableAttributedString(string: goalTitle, attributes: attributes)
            
            let goalDesc = "\n\(history.goals[indexPath.row].goalDescription)"
            
            let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-Regular", size: 14.0),.foregroundColor: UIColor(hexString: "#9B9B9B")]
            let attributedDescText = NSMutableAttributedString(string: goalDesc, attributes: descAttributes)
            
            attributedInfoText.append(attributedDescText)
            goalsLabel.attributedText = attributedInfoText
            
            cell.addSubview(divider)
            cell.addSubview(goalsView)
            goalsView.addSubview(rowIndex)
            cell.addSubview(goalsLabel)
            
            NSLayoutConstraint.activate([
                divider.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                divider.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                divider.heightAnchor.constraint(equalToConstant: 1.0),
                divider.topAnchor.constraint(equalTo: cell.topAnchor),
                goalsView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 14.0),
                goalsView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 14.0),
                goalsView.heightAnchor.constraint(equalToConstant: 24.0),
                goalsView.widthAnchor.constraint(equalTo: goalsView.heightAnchor),
                rowIndex.centerXAnchor.constraint(equalTo: goalsView.centerXAnchor),
                rowIndex.centerYAnchor.constraint(equalTo: goalsView.centerYAnchor),
                goalsLabel.topAnchor.constraint(equalTo: goalsView.topAnchor),
                goalsLabel.leadingAnchor.constraint(equalTo: goalsView.trailingAnchor, constant: 14.0),
                goalsLabel.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -14.0),
                goalsLabel.bottomAnchor.constraint(lessThanOrEqualTo: cell.bottomAnchor, constant: -14.0)
            ])
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.getHeader(with: CommonHeader.self, index: section) as? CommonHeader else { return nil }
        if section == 0 {
            let headerlabel = UILabel()
            headerlabel.text = "Recorded Symptoms"
            headerlabel.font = UIFont(name: "Montserrat-Regular", size: 18.0)
            headerlabel.textColor = UIColor(hexString: "#4E4E4E")
            headerlabel.translatesAutoresizingMaskIntoConstraints = false
            
            header.addSubview(headerlabel)
            NSLayoutConstraint.activate([
                headerlabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10.0),
                headerlabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
            ])
            header.backgroundColor = .white
            return header
        } else if section == 1 {
            let headerlabel = UILabel()
            headerlabel.text = "Insights"
            headerlabel.font = UIFont(name: "Montserrat-SemiBold", size: 24.0)
            headerlabel.textColor = UIColor(hexString: "#4E4E4E")
            headerlabel.translatesAutoresizingMaskIntoConstraints = false
            
            header.addSubview(headerlabel)
            NSLayoutConstraint.activate([
                headerlabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10.0),
                headerlabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
            ])
            header.backgroundColor = .white
            return header
        } else {
            let headerlabel = UILabel()
            headerlabel.text = "Your next \(history.goals.count) goal(s)"
            headerlabel.font = UIFont(name: "Montserrat-SemiBold", size: 18.0)
            headerlabel.textColor = UIColor(hexString: "#4E4E4E")
            headerlabel.translatesAutoresizingMaskIntoConstraints = false
            
            header.addSubview(headerlabel)
            NSLayoutConstraint.activate([
                headerlabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 10.0),
                headerlabel.centerYAnchor.constraint(equalTo: header.centerYAnchor)
            ])
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < 1 {
            return 50.0
        } else {
            return 110.0
        }
    }
}


class CommonHeader: UITableViewHeaderFooterView {
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
