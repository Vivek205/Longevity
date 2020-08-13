//
//  UserInsight.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 11/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum RiskLevel: Int, Codable {
    case high = 0
    case lowLevel
    case medium
}

extension RiskLevel {
    var text: String {
        switch self {
            case .high:
                return "High Risk"
            case .medium:
                return "Medium Risk"
            case .lowLevel:
                return "Low Risk"
        }
    }
    
    var riskColor: UIColor {
        switch self {
            case .high:
                return UIColor(hexString: "#E67381")
            case .medium:
                return UIColor(hexString: "#F7C26B")
            case .lowLevel:
                return UIColor(red: 89/255.0, green: 187/255.0, blue: 110/255.0, alpha: 0.7)
        }
    }
}

enum TrendDirection: Int, Codable {
    case uptrend = 0
    case down
    case same
}

extension TrendDirection {
    var text: String {
        switch self {
            case .uptrend:
                return "TRENDING UP"
            case .down:
                return "TRENDING DOWN"
            case .same:
                return "NO TREND CHANGE"
        }
    }
    
    var tintColor: UIColor {
        switch self {
            case .uptrend:
                return UIColor(hexString: "#E67381")
            case .down:
                return UIColor(hexString: "#9B9B9B")
            case .same:
                return UIColor(hexString: "#9B9B9B")
        }
    }
    
    var trendIcon: UIImage? {
        switch self {
            case .uptrend:
                return UIImage(named: "trending_up")
            case .down:
                return UIImage(named: "trending_down")
            case .same:
                return nil
        }
    }
}

struct UserInsight: Codable {
    let cardName: String
    let cardType: String
    let description: String
    let details: UserInsightDetails
}

struct UserInsightDetails: Codable {
    let name: String
    let riskLevel: RiskLevel
    let trend: TrendDirection
    let confidence: String
    let exposureHistory: [Exposure]
}

struct Exposure: Codable {
    let recordDate: String
    let covidRisk: CovidRisk
}

struct CovidRisk: Codable {
    let noCovidRisk: Double
    let mediumCovidRisk: Double
    let lowCovidRisk: Double
    let highCovidRisk: Double
}

let insights = """
{
  "card_name": "COVID-19 Exposure",
  "card_type": "COVID",
  "description": "",
  "details": {
    "name": "covid_risk",
    "risk_level": "HIGH/LOW/MEDIUM",
    "trend": "UP/DOWN/SAME",
    "confidence": "",
    "exposure_history": [
      {
        "record_date": "12-07-2020",
        "covid_risk": {
          "no_covid_risk": 0.0028869937004576017,
          "medium_covid_risk": 0.2227494552917446,
          "low_covid_risk": 0.7687638067446652,
          "high_covid_risk": 0.0055997442631326895
        }
      }
    ]
  }
}
"""
