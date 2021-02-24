//
//  CheckInLogDetailsViewController.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 28/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class CheckInLogDetailsViewController: UIViewController {

    private var dismissalDirection: ModalDismissDirection = .downwards
    
    var logItem: History! {
        didSet {
            self.logDetailsTableView.reloadData()
            self.logTitle.text = logItem.surveyName
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            if let date = dateformatter.date(from: logItem.recordDate) {
                dateformatter.dateFormat = "MMM dd, yyyy | hh:mm a"
                dateformatter.amSymbol = "am"
                dateformatter.pmSymbol = "pm"
                self.logDate.text = dateformatter.string(from: date)
            }
        }
    }
    
    var isCoughResult: Bool {
        return logItem.surveyID?.starts(with: "COUGH_TEST") ?? false
    }
    
    lazy var transparentView: UIView = {
        let transparentview = UIView()
        transparentview.backgroundColor = .clear
        transparentview.translatesAutoresizingMaskIntoConstraints = false
        return transparentview
    }()
    
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
    
    lazy var logTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: AppFontName.semibold, size: 24.0)
        title.textColor = UIColor(hexString: "#4E4E4E")
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var logDate: UILabel = {
        let date = UILabel()
        date.font = UIFont(name: AppFontName.light, size: 18.0)
        date.textColor = UIColor(hexString: "#4E4E4E")
        date.translatesAutoresizingMaskIntoConstraints = false
        return date
    }()
    
    lazy var exportButton: UIButton = {
        let export = UIButton()
        export.setTitle("Export", for: .normal)
        export.setTitleColor(.themeColor, for: .normal)
        export.titleLabel?.font = UIFont(name: AppFontName.semibold, size: 18.0)
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
        logdetailsTable.backgroundColor = .clear
        logdetailsTable.translatesAutoresizingMaskIntoConstraints = false
        return logdetailsTable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.view.addSubview(transparentView)
        self.view.addSubview(containerView)
        self.containerView.addSubview(bezelView)
        self.containerView.addSubview(logTitle)
        self.containerView.addSubview(logDate)
        self.containerView.addSubview(exportButton)
        self.containerView.addSubview(logDetailsTableView)
        
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: self.view.topAnchor),
            transparentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            transparentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: transparentView.bottomAnchor, constant: -20.0),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.75),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bezelView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 13.0),
            bezelView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bezelView.heightAnchor.constraint(equalToConstant: 5.0),
            bezelView.widthAnchor.constraint(equalToConstant: 36.0),
            logTitle.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25.0),
            logTitle.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25.0),
            logTitle.topAnchor.constraint(equalTo: bezelView.bottomAnchor, constant: 15.0),
            logDate.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 25.0),
            logDate.topAnchor.constraint(equalTo: logTitle.bottomAnchor, constant: 22.0),
            exportButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -25.0),
            exportButton.centerYAnchor.constraint(equalTo: logDate.centerYAnchor),
            exportButton.widthAnchor.constraint(equalToConstant: 110.0),
            exportButton.heightAnchor.constraint(equalToConstant: 32.0),
            exportButton.leadingAnchor.constraint(greaterThanOrEqualTo: logDate.trailingAnchor, constant: 10.0),
            logDetailsTableView.topAnchor.constraint(equalTo: exportButton.bottomAnchor, constant: 25.0),
            logDetailsTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            logDetailsTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            logDetailsTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        containerView.frame = CGRect(x: 0.0, y: self.view.bounds.height,
                                     width: self.view.bounds.width,
                                     height: self.view.bounds.height * 0.75)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(closeView))
        tapgesture.numberOfTouchesRequired = 1

        self.transparentView.addGestureRecognizer(tapgesture)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        containerView.addGestureRecognizer(gesture)
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleExportData() {
        self.showSpinner()
        UserInsightsAPI.instance.exportUserApplicationData(submissionID: logItem?.submissionID, completion: { [unowned self] in
            DispatchQueue.main.async {
                Alert(title: "Success", message: "Your data has been sent to your email.")
                self.removeSpinner()
            }
        }) { [unowned self] (error) in
            DispatchQueue.main.async {
                self.removeSpinner()
                Alert(title: "Failure", message: "Unable to export your data. Please try again later.")
            }
        }
    }
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    @objc func wasDragged(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            if viewTranslation.y < 0 {
                return
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.containerView.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
            })
        case .ended:
            if viewTranslation.y > -100 && viewTranslation.y < 200 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.containerView.transform = .identity
                })
            } else {
                if viewTranslation.y >= 0 {
                    self.dismissalDirection = .downwards
                    dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
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
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
            self.containerView.frame = CGRect(x: 0.0, y: self.view.bounds.height * 0.75,
                                              width: self.view.bounds.width, height: self.view.bounds.height * 0.75)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
            if self.dismissalDirection == .downwards {
                self.containerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y * 2)
            }
        }
    }
}

extension CheckInLogDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 1
        if self.isCoughResult {
            sections += 1
        } else {
            if (logItem?.symptoms.count ?? 0) > 0 {
                sections += 1
            }
            if (logItem?.insights.count ?? 0) > 0 {
                sections += 1
            }
        }
        
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && self.isCoughResult {
            return 1
        } else if section == 0 && (logItem?.symptoms.count ?? 0) > 0 {
            return  logItem.symptoms.count
        } else if (section == 0 || section == 1) && (logItem?.insights.count ?? 0) > 0 {
            return logItem.insights.count
        } else {
            return logItem.goals.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && self.isCoughResult {
                guard let cell = tableView.getCell(with: CoughLogResultCell.self, at: indexPath) as? CoughLogResultCell else {
                    preconditionFailure("Invalid cell type")
                }
                return cell
            } else if indexPath.section == 0 && (logItem?.symptoms.count ?? 0) > 0 {
                guard let cell = tableView.getCell(with: CheckinLogSymptomsCell.self, at: indexPath) as? CheckinLogSymptomsCell else {
                    preconditionFailure("Invalid cell type")
                }
                cell.symptom = logItem?.symptoms[indexPath.row]
                return cell
            }
            else if (indexPath.section == 0 || indexPath.section == 1) && (logItem?.insights.count ?? 0) > 0 {
                guard let cell = tableView.getCell(with: CheckinLogInsightCell.self, at: indexPath) as? CheckinLogInsightCell else {
                    preconditionFailure("Invalid cell type")
                }
                cell.insight = logItem?.insights[indexPath.row]
                return cell
            } else {
                guard let cell = tableView.getCell(with: CheckinLogGoal.self, at: indexPath) as? CheckinLogGoal else {
                    preconditionFailure("Invalid cell type")
                }
                cell.setup(goal: logItem.goals[indexPath.row], index: indexPath.row)
                return cell
            }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.getHeader(with: CommonHeader.self, index: section) as? CommonHeader else { return nil }
        if section == 0 && self.isCoughResult {
            return header
        } else if section == 0 && (logItem?.symptoms.count ?? 0) > 0  {
            header.setupHeaderText(font: UIFont(name: AppFontName.regular, size: 18.0), title: "Recorded Symptoms")
        } else if (section == 0 || section == 1) && (logItem?.insights.count ?? 0) > 0 {
            header.setupHeaderText(font: UIFont(name: AppFontName.semibold, size: 24.0), title: "Insights")
        } else {
            header.setupHeaderText(font: UIFont(name: AppFontName.semibold, size: 18.0), title: "Your next \(logItem.goals.count) goal(s)")
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.isCoughResult {
            return 0.0
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && self.isCoughResult {
            let textheader = "According to our cough classifier:"
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.medium, size: 14.0),
                                                             .foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedCoughResult = NSMutableAttributedString(string: textheader, attributes: attributes)
            
            let insightTitle = "\n\(logItem.resultDescription?.text ?? "")"
            
            let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 24.0),
                                                              .foregroundColor: UIColor(hexString: "#4E4E4E")]
            attributedCoughResult.append(NSMutableAttributedString(string: insightTitle, attributes: attributes2))
            
            let insightText = "\n\(logItem.resultDescription?.goalDescription ?? "")"
            
            let attributes3: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.italic, size: 18.0),
                                                              .foregroundColor: UIColor(hexString: "#4E4E4E")]
            attributedCoughResult.append(NSMutableAttributedString(string: insightText, attributes: attributes3))
            let textAreaWidth = tableView.bounds.width - 28.0
            var goalHeight = 14.0 + attributedCoughResult.height(containerWidth: textAreaWidth)
            goalHeight += 14.0
            return goalHeight
        } else if indexPath.section == 0 && (logItem?.symptoms.count ?? 0) > 0 {
            return 50.0
        } else if (indexPath.section == 0 || indexPath.section == 1) && (logItem?.insights.count ?? 0) > 0 {
            return 110.0
        } else {
            let goal = logItem.goals[indexPath.row]
            
            let insightTitle = goal.text
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 18.0),.foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedinsightTitle = NSMutableAttributedString(string: insightTitle, attributes: attributes)
            
            let textAreaWidth = tableView.bounds.width - 96.0
            
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
