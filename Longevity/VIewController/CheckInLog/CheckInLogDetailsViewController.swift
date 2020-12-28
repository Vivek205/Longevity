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
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
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
            bezelView.heightAnchor.constraint(equalToConstant: 5.0),
            bezelView.widthAnchor.constraint(equalToConstant: 36.0),
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
        
        containerView.frame = CGRect(x: 0.0, y: self.view.bounds.height,
                                     width: self.view.bounds.width, height: self.view.bounds.height / 2.0)
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleExportData() {
        let userInsightAPI = UserInsightsAPI()
        self.showSpinner()
        userInsightAPI.exportUserApplicationData(completion: {
            DispatchQueue.main.async {
                Alert(title: "Success", message: "Your data has been sent to your email.")
                self.removeSpinner()
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.removeSpinner()
                Alert(title: "Failure", message: "Unable to export your data. Please try again later.")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.containerView.layer.cornerRadius = 20.0
        self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.containerView.layer.masksToBounds = true
        
        self.bezelView.layer.cornerRadius = 2.5
        self.bezelView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
            self.containerView.frame = CGRect(x: 0.0, y: self.view.bounds.height / 2.0, width: self.view.bounds.width, height: self.view.bounds.height / 2.0)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
            self.containerView.frame = CGRect(x: 0.0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height / 2.0)
        }
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
            guard let cell = tableView.getCell(with: CheckinLogSymptomsCell.self, at: indexPath) as? CheckinLogSymptomsCell else {
                preconditionFailure("Invalid cell type")
            }
            cell.symptom = history.symptoms[indexPath.row]
            return cell
        }
        else if indexPath.section == 1 {
            guard let cell = tableView.getCell(with: CheckinLogInsightCell.self, at: indexPath) as? CheckinLogInsightCell else {
                preconditionFailure("Invalid cell type")
            }
            cell.insight = history.insights[indexPath.row]
            return cell
        } else {
            guard let cell = tableView.getCell(with: CheckinLogGoal.self, at: indexPath) as? CheckinLogGoal else {
                preconditionFailure("Invalid cell type")
            }
            cell.setup(goal: history.goals[indexPath.row], index: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.getHeader(with: CommonHeader.self, index: section) as? CommonHeader else { return nil }
        if section == 0 {
            header.setupHeaderText(font: UIFont(name: AppFontName.regular, size: 18.0), title: "Recorded Symptoms")
        } else if section == 1 {
            header.setupHeaderText(font: UIFont(name: AppFontName.semibold, size: 24.0), title: "Insights")
        } else {
            header.setupHeaderText(font: UIFont(name: AppFontName.semibold, size: 18.0), title: "Your next \(history.goals.count) goal(s)")
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < 1 {
            return 50.0
        } else if indexPath.section == 1 {
            return 110.0
        } else {
            let goal = history.goals[indexPath.row]
            
            let insightTitle = goal.text
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Montserrat-SemiBold", size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedinsightTitle = NSMutableAttributedString(string: insightTitle, attributes: attributes)
            
            let textAreaWidth = tableView.bounds.width - 66.0
            
            var goalHeight = 14.0 + attributedinsightTitle.height(containerWidth: textAreaWidth)
            
            if !goal.goalDescription.isEmpty {
                let insightDesc = "\n\n\(goal.goalDescription)"
                
                let descAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular,
                                                                                   size: 14.0),
                                                                     .foregroundColor: UIColor(hexString: "#4E4E4E")]
                let attributedDescText = NSMutableAttributedString(string: insightDesc, attributes: descAttributes)
                attributedinsightTitle.append(attributedDescText)
                
                goalHeight += attributedinsightTitle.height(containerWidth: textAreaWidth)
            }
            
            if let citation = goal.citation, !citation.isEmpty {
                let linkAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular,
                                                                                   size: 14.0),
                                                                     .foregroundColor: UIColor(red: 0.05,
                                                                                               green: 0.4, blue: 0.65, alpha: 1.0),
                                                                     .underlineStyle: NSUnderlineStyle.single]
                let attributedCitationText = NSMutableAttributedString(string: citation,
                                                                       attributes: linkAttributes)
                goalHeight += attributedCitationText.height(containerWidth: textAreaWidth)
                goalHeight += 10.0
            }
            
            goalHeight += 14.0
            
            return goalHeight
        }
    }
}


class CommonHeader: UITableViewHeaderFooterView {
    
    lazy var headerlabel: UILabel = {
        let headerlabel = UILabel()
        headerlabel.text = ""
        headerlabel.font = UIFont(name: "Montserrat-SemiBold", size: 18.0)
        headerlabel.textColor = UIColor(hexString: "#4E4E4E")
        headerlabel.translatesAutoresizingMaskIntoConstraints = false
        return headerlabel
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        view.addSubview(headerlabel)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.0),
            headerlabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
            headerlabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHeaderText(font: UIFont?, title: String) {
        self.headerlabel.text = title
        self.headerlabel.font = font
    }
}
