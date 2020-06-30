//
//  OnboardingContent.swift
//  Longevity
//
//  Created by vivek on 10/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation
import UIKit

struct OnboardingContent {
    let images: [UIImage] = [ #imageLiteral(resourceName: "onboardingOne") , #imageLiteral(resourceName: "onboardingTwo"), #imageLiteral(resourceName: "onboardingThree")]
    let pageHeadings:[String] = [
        "Discover Yourself in new ways with AI",
        "Connect your Health data in one place"
        ,
        "Ready to explore yourself?"]
    let pageDescriptions:[String] = [
        "Let us help you to find useful aspects of your health that supports you and health research."
        ,
        "Our mission is to connect people with the places in which they spend their time."
        ,
        "Our app offers comprehensive guides and analysis about you."]

    var imageCount:Int{
        return images.count
    }
}
