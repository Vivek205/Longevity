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
            self.insightDescription.text = insightData?.userInsightDescription
            if let details = insightData?.details {
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
    
    lazy var trendHistogram: UILabel = {
        let histogram = UILabel()
        histogram.text = "Trend Historgram"
        histogram.font = UIFont(name: "Montserrat-Medium", size: 16.0)
        histogram.textColor = UIColor(hexString: "#4E4E4E")
        histogram.translatesAutoresizingMaskIntoConstraints = false
        return histogram
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
        histogramView.noDataText = "More data needed"
        histogramView.noDataFont = UIFont(name: "Montserrat-Regular", size: 12.0)!
        histogramView.noDataTextColor = UIColor(hexString: "#9B9B9B")
        histogramView.noDataTextAlignment = .center
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
    
    lazy var chartNoDataLabel: UILabel = {
        let chartnodata = UILabel()
        chartnodata.text = "More data needed"
        chartnodata.font = UIFont(name: "Montserrat-Regular", size: 12.0)
        chartnodata.textColor = UIColor(hexString: "#9B9B9B")
        chartnodata.textAlignment = .center
        chartnodata.translatesAutoresizingMaskIntoConstraints = false
        return chartnodata
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(insightDescription)
        self.addSubview(divider1)
        self.addSubview(trendHistogram)
        self.addSubview(histogramView)
        self.addSubview(histogramDescription)
        self.addSubview(chartNoDataLabel)
        
        NSLayoutConstraint.activate([
            insightDescription.topAnchor.constraint(equalTo: topAnchor),
            insightDescription.leadingAnchor.constraint(equalTo: leadingAnchor),
            insightDescription.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider1.topAnchor.constraint(equalTo: insightDescription.bottomAnchor, constant: 8.0),
            divider1.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider1.heightAnchor.constraint(equalToConstant: 1.0),
            divider1.trailingAnchor.constraint(equalTo: trailingAnchor),
            trendHistogram.leadingAnchor.constraint(equalTo: leadingAnchor),
            trendHistogram.topAnchor.constraint(equalTo: divider1.bottomAnchor, constant: 8.0),
            histogramView.topAnchor.constraint(equalTo: trendHistogram.bottomAnchor, constant: 8.0),
            histogramView.leadingAnchor.constraint(equalTo: leadingAnchor),
            histogramView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chartNoDataLabel.leadingAnchor.constraint(equalTo: histogramView.leadingAnchor),
            chartNoDataLabel.trailingAnchor.constraint(equalTo: histogramView.trailingAnchor),
            chartNoDataLabel.centerYAnchor.constraint(equalTo: histogramView.centerYAnchor),
            histogramDescription.topAnchor.constraint(equalTo: histogramView.bottomAnchor, constant: 8.0),
            histogramDescription.leadingAnchor.constraint(equalTo: leadingAnchor),
            histogramDescription.trailingAnchor.constraint(equalTo: trailingAnchor),
            histogramDescription.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        self.chartNoDataLabel.isHidden = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Removing all existing layers
        if let layers = histogramView.layer.sublayers {
            for layer in layers {
                if let name = layer.name, name.contains("gradLayer") {
                    layer.removeFromSuperlayer()
                }
            }
        }

        let layerGradient = CAGradientLayer()
        layerGradient.name = "gradLayer"
        layerGradient.frame = histogramView.contentRect//CGRect(x: 0, y: 0, width: histogramView.bounds.width, height: histogramView.bounds.height)
        let color1 = UIColor(red: 230.0/255.0, green: 115.0/255.0, blue: 129.0/255.0, alpha: 1.0).withAlphaComponent(0.3).cgColor
        let color2 = UIColor.white.withAlphaComponent(0.3).cgColor
        let color3 = UIColor(red: 89.0/255.0, green: 187.0/255.0, blue: 110.0/255.0, alpha: 1.0).withAlphaComponent(0.3).cgColor
        layerGradient.colors = [color1, color2, color3]//[UIColor(hexString: "#F5F6FA").withAlphaComponent(0.0).cgColor, UIColor(hexString: "#F5F6FA").cgColor]
        layerGradient.locations = [0.0, 0.5, 1.0]

        histogramView.layer.insertSublayer(layerGradient, at: 0)
    }
    
    var referenceTimeInterval: TimeInterval = 0
    
    fileprivate func createHistogramData() {
        if let submissions = insightData?.details?.submissions?.suffix(14), !submissions.isEmpty {
            if let minTimeInterval = (submissions.map { (DateUtility.getDate(from: $0.recordDate)?.timeIntervalSince1970 ?? 0) }).min() {
                referenceTimeInterval = minTimeInterval
            }
            
            let chartDataEntry = submissions.map { ChartDataEntry(x: self.parseDate(recordDate: $0.recordDate), y: Double($0.value) ?? 0.0) }.sorted { $0.x < $1.x }

            let line = LineChartDataSet(entries: chartDataEntry, label: "Risk")
            line.drawCircleHoleEnabled = false
            line.drawValuesEnabled = false
            line.lineWidth = 2.0
            line.setColor(UIColor(hexString: "#6C8CBF"))
            line.circleRadius = 5
            line.setCircleColor(UIColor(hexString: "#6C8CBF"))
            let data = LineChartData(dataSet: line)
            self.histogramView.data = data
            self.histogramView.dragXEnabled = true
            self.histogramView.xAxis.granularity = 1
            let formatter = DateFormatter()
            formatter.dateFormat = "dd\nMMM"

            let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)
             xValuesNumberFormatter.dateFormatter = formatter
            
            self.histogramView.xAxis.valueFormatter = xValuesNumberFormatter
            self.chartNoDataLabel.isHidden = true
        }
    }

    fileprivate func parseDate(recordDate: String) -> Double {
        if let date = DateUtility.getDate(from: recordDate) {
            let timeInterval = date.timeIntervalSince1970
            return (timeInterval - referenceTimeInterval) / (3600 * 24)
        }
        return 0.0
    }
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    fileprivate var referenceTimeInterval: TimeInterval?

    convenience init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
}


extension ChartXAxisFormatter: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
        let referenceTimeInterval = referenceTimeInterval
        else {
            return ""
        }

        let date = Date(timeIntervalSince1970: value * 3600 * 24 + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }
}
