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
            if !logItem.recordDate.isEmpty {
                let toformat = self.isCoughResult ? "MMM dd, yyyy | hh:mm a" : "MMM dd, yyyy"
                self.logDate.text = DateUtility.getString(from: logItem.recordDate, toFormat: toformat)
            }
        }
    }
    
    var isCoughResult: Bool {
        return logItem.surveyID?.starts(with: Strings.coughTest) ?? false
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
