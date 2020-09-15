//
//  RecordedSymptomsDetailView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 08/09/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class RecordedSymptomsDetailView: UIView {
    var symptoms: [String]? {
        didSet {
            self.symptomsTableView.reloadData()
        }
    }
    
    lazy var detailsDescription: UILabel = {
        let insightdesc = UILabel()
        insightdesc.numberOfLines = 0
        insightdesc.lineBreakMode = .byWordWrapping
        insightdesc.text = "These are the symptoms you reported"
        insightdesc.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        insightdesc.textColor = UIColor(hexString: "#9B9B9B")
        insightdesc.translatesAutoresizingMaskIntoConstraints = false
        return insightdesc
    }()
    
    lazy var divider1: UIView = {
        let divider = UIView()
        divider.backgroundColor = UIColor(hexString: "#CECECE")
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }()
    
    lazy var symptomsTableView: UITableView = {
        let symptomsTable = UITableView(frame: CGRect.zero, style: .plain)
        symptomsTable.delegate = self
        symptomsTable.dataSource = self
        symptomsTable.allowsSelection = false
        symptomsTable.tableFooterView = UIView()
        symptomsTable.translatesAutoresizingMaskIntoConstraints = false
        return symptomsTable
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(detailsDescription)
        self.addSubview(divider1)
        self.addSubview(symptomsTableView)
        
        NSLayoutConstraint.activate([
            detailsDescription.topAnchor.constraint(equalTo: topAnchor),
            detailsDescription.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailsDescription.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider1.topAnchor.constraint(equalTo: detailsDescription.bottomAnchor, constant: 14.0),
            divider1.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider1.heightAnchor.constraint(equalToConstant: 1.0),
            divider1.trailingAnchor.constraint(equalTo: trailingAnchor),
            symptomsTableView.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 15.0),
            symptomsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            symptomsTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.0),
            symptomsTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecordedSymptomsDetailView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.symptoms?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.getCell(with: RecordedSymptomTableCell.self, at: indexPath) as? RecordedSymptomTableCell else { preconditionFailure("Invalid symptom cell")}
        
        guard let symptom = self.symptoms?[indexPath.item] else {
            preconditionFailure("Symptom not available")
        }
        cell.symptom = symptom
        return cell
    }
}

class RecordedSymptomTableCell: UITableViewCell {
    
        var symptom: String! {
            didSet {
                self.symptomLabel.text = symptom
            }
        }
        
        lazy var symptomLabel: UILabel = {
            let symptomLabel = UILabel()
            symptomLabel.font = UIFont(name: "Montserrat-Regular", size: 18.0)
            symptomLabel.numberOfLines = 0
            symptomLabel.textColor = UIColor(hexString: "#4E4E4E")
            symptomLabel.translatesAutoresizingMaskIntoConstraints = false
            return symptomLabel
        }()
        
        lazy var checkImage: UIImageView = {
            let checkImage = UIImageView()
            checkImage.image = UIImage(named: "icon: checkbox-selected")
            checkImage.contentMode = .scaleAspectFit
            checkImage.translatesAutoresizingMaskIntoConstraints = false
            return checkImage
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            backgroundColor = .white
            
            addSubview(symptomLabel)
            addSubview(checkImage)
            NSLayoutConstraint.activate([
                symptomLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14.0),
                symptomLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5.0),
                symptomLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5.0),
                checkImage.leadingAnchor.constraint(greaterThanOrEqualTo: symptomLabel.trailingAnchor, constant: 10.0),
                checkImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14.0),
                checkImage.centerYAnchor.constraint(equalTo: centerYAnchor),
                checkImage.widthAnchor.constraint(equalToConstant: 24.0),
                checkImage.heightAnchor.constraint(equalTo: checkImage.widthAnchor)
            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
