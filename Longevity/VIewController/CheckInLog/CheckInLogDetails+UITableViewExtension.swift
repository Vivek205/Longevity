//
//  CheckInLogDetails+UITableViewExtension.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 25/02/2021.
//  Copyright © 2021 vivek. All rights reserved.
//

import UIKit

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
                cell.coughResultDescription = logItem?.resultDescription
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
            let headertitle = self.isCoughResult ? "COVID-19 PREVENTION GUIDELINES" : "YOUR NEXT GOALS"
            header.setupHeaderText(font: UIFont(name: AppFontName.medium, size: 14.0), title: headertitle)
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
            if let resultDescription = logItem.resultDescription {
                let textheader = "According to our cough classifier:"
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.medium, size: 14.0),
                                                                 .foregroundColor: UIColor(hexString: "#4E4E4E")]
                let attributedCoughResult = NSMutableAttributedString(string: textheader, attributes: attributes)
                
                let insightTitle = "\n\n\(resultDescription.shortDescription)"
                
                let attributes2: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.semibold, size: 24.0),
                                                                  .foregroundColor: UIColor(hexString: "#4E4E4E")]
                attributedCoughResult.append(NSMutableAttributedString(string: insightTitle, attributes: attributes2))
                
                let insightText = "\n\n\(resultDescription.longDescription)"
                
                let attributes3: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.italic, size: 18.0),
                                                                  .foregroundColor: UIColor(hexString: "#4E4E4E")]
                attributedCoughResult.append(NSMutableAttributedString(string: insightText, attributes: attributes3))
                let textAreaWidth = tableView.bounds.width - 28.0
                var descriptionHeight = 14.0 + attributedCoughResult.height(containerWidth: textAreaWidth)
                descriptionHeight += 14.0
                return descriptionHeight
            } else {
                return 0.0
            }
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
