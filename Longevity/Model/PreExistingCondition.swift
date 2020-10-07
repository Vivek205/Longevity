//
//  PreExistingCondition.swift
//  Longevity
//
//  Created by vivek on 14/07/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

enum PreExistingMedicalConditionId: String {
    case cardiovascularDisease = "CARDIVASCULAR_DISEASE"
    case diabetes = "DIABETES"
    case highBloodPressure = "HIGH_BLOOD_PRESSURE"
    case lungDisease = "LUNG_DISEASE"
    case kidneyDisease = "KIDNEY_DISEASE"
    case cancer = "CANCER"
    case immunocompromised = "IMMUNOCOMPROMISED"
    case psychologicalDisorder = "PSYCHOLOGICAL_DISORDER"
}

struct PreExistingMedicalConditionModel {
    let id: PreExistingMedicalConditionId
    let name: String
    let description: String
    var selected: Bool = false
    var touched: Bool = false
}


var preExistingMedicalConditionData:[PreExistingMedicalConditionModel] = [
    PreExistingMedicalConditionModel(id: .cardiovascularDisease,name: "Cardiovascular Disease", description: "Examples: angina, heart attacks, heart failures, coronary heart disease,strokes, peripheral arterial disease, aortic disease, etc"),
    PreExistingMedicalConditionModel(id:.diabetes,name: "Diabetes", description: "Type 1 Diabetes or Type 2 Diabetes."),
    PreExistingMedicalConditionModel(id:.highBloodPressure,name: "High Blood Pressure", description: "primary hypertension (not related to another medical condition),secondary hypertension (caused by a medical condition)."),
    PreExistingMedicalConditionModel(id:.lungDisease,name: "Lung Disease", description: "asthma, pneumonia, bronchitis, or chronic obstructive pulmonary disease (COPD)."),
    PreExistingMedicalConditionModel(id:.kidneyDisease,name: "Kidney Disease", description: "kidney stones, chronic kidney disease, glomerulonephritis,polycystic kidney disease, or urinary tract infections."),
    PreExistingMedicalConditionModel(id:.cancer,name: "Cancer", description: "Examples: breast cancer, lung cancer, prostate cancer, kidney cancer, or leukemia."),
    PreExistingMedicalConditionModel(id:.immunocompromised,name: "Immunocompromised", description: "Your immune system has been diagnosed as being impaired. Some conditions and treatments can weaken your immune system such as cancer  or post-transplant treatments, and HIV."),
    PreExistingMedicalConditionModel(id:.psychologicalDisorder,name: "Psychological Disorder(s)", description: "Examples: depression, anxiety disorders, eating disorder, PTSD, OCD, bipolar disorder, personality disorder, or schizophrenia.")
]

var preExistingMedicalCondtionOtherText: String?
