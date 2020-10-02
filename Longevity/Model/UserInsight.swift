//
//  UserInsight.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 11/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

enum RiskLevel: String, Codable {
    case high = "HIGH"
    case lowLevel = "LOW"
    case medium = "MEDIUM"
    case none = "More data needed"
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
        default:
                return "More data needed"
        }
    }
    
    var textFont: UIFont? {
        switch self {
        case .none:
            return UIFont(name: "Montserrat-Regular", size: 12.0)
        default:
            return UIFont(name: "Montserrat-SemiBold", size: 18.0)
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
        default:
            return UIColor(hexString: "#9B9B9B")
        }
    }
    
    var riskIcon: UIImage? {
        switch self {
            case .high:
                return UIImage(named: "high-risk")
            case .medium:
                return UIImage(named: "medium-risk")
            case .lowLevel:
                return UIImage(named: "low-risk")
        default:
            return UIImage(named: "risk-null")
        }
    }
}

enum TrendDirection: String, Codable {
    case uptrend = "UP"
    case down = "DOWN"
    case same = "SAME"
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

enum Sentiment: String, Codable {
    case positive = "POSITIVE"
    case negative = "NEGATIVE"
    case neutral = "NEUTRAL"
}

extension Sentiment {
    var tintColor: UIColor {
        switch self {
            case .positive:
                return UIColor(hexString: "#59BB6E")
            case .negative:
                return UIColor(hexString: "#E67381")
            case .neutral:
                return UIColor(hexString: "#59BB6E")
        }
    }
}

enum CardType: String, Codable {
    case logs = "COVID_LOGS"
    case exposure = "COVID_EXPOSURE"
    case risk = "COVID_RISK"
    case distancing = "SOCIAL_DISTANCING"
}

struct UserInsight: Codable {
    let name: CardType
    let text, userInsightDescription: String
    let defaultOrder: Int
    var details: Details?
    var isExpanded: Bool?
    
    enum CodingKeys: String, CodingKey {
        case text, name
        case userInsightDescription = "description"
        case defaultOrder = "default_order"
        case details
    }
}

// MARK: - Details
struct Details: Codable {
    let lastLogged: String?
    let history: [History]?
    var riskLevel: RiskLevel?
    let trending: TrendDirection?
    let sentiment: Sentiment?
    let confidence: Confidence?
    let histogram: Histogram?
    let submissions: [Submission]?

    enum CodingKeys: String, CodingKey {
        case lastLogged = "last_logged"
        case history
        case riskLevel = "risk_level"
        case trending, sentiment, confidence, histogram, submissions
    }
}

// MARK: - Confidence
struct Confidence: Codable {
    let value, confidenceDescription: String?

    enum CodingKeys: String, CodingKey {
        case value
        case confidenceDescription = "description"
    }
}

// MARK: - Histogram
struct Histogram: Codable {
    let histogramDescription: String

    enum CodingKeys: String, CodingKey {
        case histogramDescription = "description"
    }
}

// MARK: - History
struct History: Codable {
    let recordDate, submissionID: String
    let symptoms: [String]
    let insights, goals: [Goal]

    enum CodingKeys: String, CodingKey {
        case recordDate = "record_date"
        case submissionID = "submission_id"
        case symptoms, insights, goals
    }
}

// MARK: - Goal
struct Goal: Codable {
    let text, goalDescription: String

    enum CodingKeys: String, CodingKey {
        case text
        case goalDescription = "description"
    }
}

// MARK: - Submission
struct Submission: Codable {
    let recordDate, submissionID, value: String

    enum CodingKeys: String, CodingKey {
        case recordDate = "record_date"
        case submissionID = "submission_id"
        case value
    }
}
