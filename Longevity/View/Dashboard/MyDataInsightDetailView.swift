//
//  MyDataInsightDetailView.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 28/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import Charts

class MyDataInsightDetailView: UIView {
    var insightData: UserInsight! {
        didSet {
            if let details = insightData?.details {
                self.insightDescription.text = insightData.userInsightDescription
                self.confidenceValue.text = details.confidence?.value
                self.confidenceDescription.text = details.confidence?.confidenceDescription
                self.histogramDescription.text = details.histogram?.histogramDescription
                self.createHistogramData()
            }
        }
    }
    
    lazy var insightDescription: UILabel = {
        let insightdesc = UILabel()
        insightdesc.numberOfLines = 0
        insightdesc.lineBreakMode = .byWordWrapping
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
    
    lazy var confidence: UILabel = {
        let confidence = UILabel()
        confidence.text = "Confidence"
        confidence.font = UIFont(name: "Montserrat-Medium", size: 16.0)
        confidence.textColor = UIColor(hexString: "#4E4E4E")
        confidence.translatesAutoresizingMaskIntoConstraints = false
        return confidence
    }()
    
    lazy var confidenceValue: UILabel = {
        let confidence = UILabel()
        confidence.text = "Medium"
        confidence.font = UIFont(name: "Montserrat-SemiBold", size: 16.0)
        confidence.textColor = .themeColor
        confidence.translatesAutoresizingMaskIntoConstraints = false
        return confidence
    }()
    
    lazy var confidenceDescription: UILabel = {
        let confidenceDesc = UILabel()
        confidenceDesc.numberOfLines = 0
        confidenceDesc.lineBreakMode = .byWordWrapping
        confidenceDesc.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        confidenceDesc.textColor = UIColor(hexString: "#9B9B9B")
        confidenceDesc.translatesAutoresizingMaskIntoConstraints = false
        return confidenceDesc
    }()
    
    lazy var divider2: UIView = {
        let divider = UIView()
        divider.backgroundColor = UIColor(hexString: "#CECECE")
        divider.translatesAutoresizingMaskIntoConstraints = false
        return divider
    }()
    
    lazy var trendHistogram: UILabel = {
        let histogram = UILabel()
        histogram.text = "Trend Historgram"
        histogram.font = UIFont(name: "Montserrat-Medium", size: 16.0)
        histogram.textColor = UIColor(hexString: "#4E4E4E")
        histogram.translatesAutoresizingMaskIntoConstraints = false
        return histogram
    }()
    
    lazy var histogramDay: UILabel = {
        let histogramDay = UILabel()
        histogramDay.text = "Today"
        histogramDay.font = UIFont(name: "Montserrat-SemiBold", size: 16.0)
        histogramDay.textColor = .themeColor
        histogramDay.translatesAutoresizingMaskIntoConstraints = false
        return histogramDay
    }()
    
    lazy var histogramDescription: UILabel = {
        let histogramDesc = UILabel()
        histogramDesc.text = ""
        histogramDesc.numberOfLines = 0
        histogramDesc.lineBreakMode = .byWordWrapping
        histogramDesc.font = UIFont(name: "Montserrat-Regular", size: 14.0)
        histogramDesc.textColor = UIColor(hexString: "#9B9B9B")
        histogramDesc.translatesAutoresizingMaskIntoConstraints = false
        return histogramDesc
    }()
    
    lazy var histogramView: LineChartView = {
        let histogramView = LineChartView()
        histogramView.rightAxis.enabled = false
        let leftAxis = histogramView.leftAxis
        leftAxis.calculate(min: -1.0, max: 1.0)
        leftAxis.axisMinimum = -1.0
        leftAxis.axisMaximum = 1.0
        leftAxis.setLabelCount(3, force: true)
        
        let xAxis = histogramView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        xAxis.avoidFirstLastClippingEnabled = true
        histogramView.isUserInteractionEnabled = false
        histogramView.translatesAutoresizingMaskIntoConstraints = false
        return histogramView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(insightDescription)
        self.addSubview(divider1)
        self.addSubview(confidence)
        self.addSubview(confidenceValue)
        self.addSubview(confidenceDescription)
        self.addSubview(divider2)
        self.addSubview(trendHistogram)
        self.addSubview(histogramDay)
        self.addSubview(histogramView)
        self.addSubview(histogramDescription)
        
        NSLayoutConstraint.activate([
            insightDescription.topAnchor.constraint(equalTo: topAnchor),
            insightDescription.leadingAnchor.constraint(equalTo: leadingAnchor),
            insightDescription.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider1.topAnchor.constraint(equalTo: insightDescription.bottomAnchor, constant: 14.0),
            divider1.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider1.heightAnchor.constraint(equalToConstant: 1.0),
            divider1.trailingAnchor.constraint(equalTo: trailingAnchor),
            confidence.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 8.0),
            confidence.leadingAnchor.constraint(equalTo: leadingAnchor),
            confidenceValue.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 8.0),
            confidenceValue.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            confidenceValue.leadingAnchor.constraint(greaterThanOrEqualTo: confidence.trailingAnchor, constant: 10.0),
            confidenceDescription.topAnchor.constraint(equalTo: confidence.bottomAnchor, constant: 8.0),
            confidenceDescription.leadingAnchor.constraint(equalTo: leadingAnchor),
            confidenceDescription.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider2.topAnchor.constraint(equalTo: confidenceDescription.bottomAnchor, constant: 14.0),
            divider2.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider2.heightAnchor.constraint(equalToConstant: 1.0),
            divider2.trailingAnchor.constraint(equalTo: trailingAnchor),
            trendHistogram.leadingAnchor.constraint(equalTo: leadingAnchor),
            trendHistogram.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 8.0),
            histogramDay.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10.0),
            histogramDay.topAnchor.constraint(equalTo: divider2.bottomAnchor, constant: 8.0),
            histogramDay.leadingAnchor.constraint(greaterThanOrEqualTo: trendHistogram.trailingAnchor, constant: 10.0),
            histogramView.topAnchor.constraint(equalTo: trendHistogram.bottomAnchor, constant: 8.0),
            histogramView.leadingAnchor.constraint(equalTo: leadingAnchor),
            histogramView.trailingAnchor.constraint(equalTo: trailingAnchor),
            histogramDescription.topAnchor.constraint(equalTo: histogramView.bottomAnchor, constant: 8.0),
            histogramDescription.leadingAnchor.constraint(equalTo: leadingAnchor),
            histogramDescription.trailingAnchor.constraint(equalTo: trailingAnchor),
            histogramDescription.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createHistogramData() {
        if let submissions = insightData?.details.submissions, !submissions.isEmpty {
            let chartDataEntry = submissions.map { ChartDataEntry(x: Double(parseDate(recordDate: $0.recordDate)), y: Double($0.value) ?? 0.0) }.sorted { $0.x < $1.x }
            
            var label = "Month"
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd"
            if let date = dateformatter.date(from: submissions[0].recordDate) {
                dateformatter.dateFormat = "MMM"
                label = dateformatter.string(from: date)
            }
            
            let line = LineChartDataSet(entries: chartDataEntry, label: label)
            line.drawCircleHoleEnabled = false
            line.drawValuesEnabled = false
            line.lineWidth = 2.0
            line.setColor(UIColor(hexString: "#6C8CBF"))
            line.circleRadius = 5
            line.setCircleColor(UIColor(hexString: "#6C8CBF"))
            let data = LineChartData()
            data.addDataSet(line)
            self.histogramView.data = data
            self.histogramView.xAxis.setLabelCount(chartDataEntry.count, force: true)
        }
    }
    
    fileprivate func parseDate(recordDate: String) -> Int {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        if let date = dateformatter.date(from: recordDate) {
            let calendar = Calendar.current
            return calendar.dateComponents([.day], from: date).day ?? 0
        }
        return 0
    }
}
