//
//  PreExistingCondition.swift
//  Longevity
//
//  Created by vivek on 14/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

struct PreExistingMedicalConditionModel {
    let id: Int
    let name: String
    let description: String
    var selected: Bool = false
    var touched: Bool = false
}


var preExistingMedicalConditionData = [
    PreExistingMedicalConditionModel(id: 0,name: "Chronic kidney disease", description: "Chronic kidney disease, also called chronic kidney failure, describes the gradual loss of kidney function."),
    PreExistingMedicalConditionModel(id:1,name: "COPD", description: "Chronic obstructive pulmonary disease (COPD) is a chronic inflammatory lung disease that causes obstructed airflow from the lungs."),
    PreExistingMedicalConditionModel(id:2,name: "Obesity", description: "Obesity is diagnosed when your body mass index (BMI) is 30 or higher."),
    PreExistingMedicalConditionModel(id:3,name: "Asthma", description: "Coughing or wheezing attacks that are worsened by a respiratory virus, such as a cold or the flu."),
    PreExistingMedicalConditionModel(id:4,name: "Hypertension", description: "Usually hypertension is defined as blood pressure above 140/90, and is considered severe if the pressure is above 180/120."),
    PreExistingMedicalConditionModel(id:5,name: "Immune deficiencies", description: "An immune deficiency disease occurs when the immune system is not working properly. If you are born with a deficiency or if there is a genetic cause")
]
