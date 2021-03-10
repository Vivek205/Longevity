//
//  AppSyncManager.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 31/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

enum TOCStatus {
    case unknown
    case accepted
    case notaccepted
    case error
}

enum InternetConnectionState {
    case connected
    case notconnected
    case none
}

enum SurveySyncStatus {
    case notstarted
    case inprogress
    case completed
    case failed
}

class AppSyncManager  {
    static let instance = AppSyncManager()
    var userProfile: DynamicValue<UserProfile>
    var healthProfile: DynamicValue<UserHealthProfile>
    var isTermsAccepted: DynamicValue<TOCStatus> = DynamicValue(.unknown)
    var appShareLink: String
    var userInsights: DynamicValue<[UserInsight]>
    var hexagonInsights: DynamicValue<[UserInsight]>
    var userNotification: DynamicValue<UserNotification>
    var userSubscriptions: DynamicValue<[UserSubscription]>
    var internetConnectionAvailable: DynamicValue<InternetConnectionState> = DynamicValue(.none)
    var prevInternetConnnection: InternetConnectionState?
    var surveysSyncStatus: DynamicValue<SurveySyncStatus> = DynamicValue(.notstarted)
    var refreshActivites: DynamicValue<Bool> = DynamicValue(false)
    
    var pollingTimer: DispatchSourceTimer?
    
    fileprivate let defaultInsights = [UserInsight(insightType: .overallInfection,
                                                   name: "Overall Infection",
                                                   userInsightDescription: "How likely you are to have COVID right now. This factors in biosignals, lifestyle and all available data.",
                                                   defaultOrder: 0,
                                                   details: Details(lastLogged: nil, history: nil, riskLevel: nil, trending: nil, sentiment: nil,
                                                                    confidence: Confidence(value: "",
                                                                                           confidenceDescription: ""),
                                                                    histogram: Histogram(histogramDescription: "Your risk over  time, based on your data and biosignals."), submissions: nil),
                                                   isExpanded: false),
                                       UserInsight(insightType: .severity,
                                                   name: "Severity Infection",
                                                   userInsightDescription: "This estimates the risk you run of having a severe reaction, if you do get COVID.",
                                                   defaultOrder: 1,
                                                   details: Details(lastLogged: nil, history: nil, riskLevel: nil, trending: nil, sentiment: nil,
                                                                    confidence: Confidence(value: "",
                                                                                           confidenceDescription: ""),
                                                                    histogram: Histogram(histogramDescription: "Your risk over  time, based on your data and biosignals."), submissions: nil),
                                                   isExpanded: false),
                                       UserInsight(insightType: .distancing,
                                                   name: "Biosignal Detection",
                                                   userInsightDescription: "How likely you have an infection (possibly but not necessarily COVID) now based on your biosignals from connected wearable devices or health trackers.",
                                                   defaultOrder: 2,
                                                   details: Details(lastLogged: nil, history: nil, riskLevel: nil, trending: nil, sentiment: nil,
                                                                    confidence: Confidence(value: "",
                                                                                           confidenceDescription: ""),
                                                                    histogram: Histogram(histogramDescription: "Your risk over  time, based on your data and biosignals."), submissions: nil),
                                                   isExpanded: false),
                                       UserInsight(insightType: .anomalousWearables,
                                                   name: "Lifestyle Infection",
                                                   userInsightDescription: "How high your risk of getting or having COVID based on your lifestyle and social distancing practices.",
                                                   defaultOrder: 3,
                                                   details: Details(lastLogged: nil, history: nil, riskLevel: nil, trending: nil, sentiment: nil,
                                                                    confidence: Confidence(value: "",
                                                                        confidenceDescription: ""),
                                                                    histogram: Histogram(histogramDescription: "Your risk over  time, based on your data and biosignals."), submissions: nil),
                                                   isExpanded: false)
    ]
    
    fileprivate init() {
        self.userProfile = DynamicValue(UserProfile(name: "User Name", email: "", phone: ""))
        self.healthProfile = DynamicValue(UserHealthProfile(weight: "", height: "", gender: "", birthday: "", unit: .metric, devices: [:], preExistingConditions: []))
        self.appShareLink = ""
        self.userNotification = DynamicValue(UserNotification(username: nil, deviceId: nil, platform: nil, endpointArn: nil, lastSent: nil, isEnabled: nil))
        self.userSubscriptions = DynamicValue([UserSubscription(subscriptionType: .longevityRelease, communicationType: .email, status: false)])
        self.userInsights = DynamicValue(self.defaultInsights)
        self.hexagonInsights = DynamicValue(self.defaultInsights)
    }
    
    func cleardata() {
        self.userProfile = DynamicValue(UserProfile(name: "User Name", email: "", phone: ""))
        self.healthProfile = DynamicValue(UserHealthProfile(weight: "", height: "", gender: "", birthday: "", unit: .metric, devices: [:], preExistingConditions: []))
        self.appShareLink = ""
        self.userNotification = DynamicValue(UserNotification(username: nil, deviceId: nil, platform: nil, endpointArn: nil, lastSent: nil, isEnabled: nil))
        self.userSubscriptions = DynamicValue([UserSubscription(subscriptionType: .longevityRelease, communicationType: .email, status: false)])
        self.userInsights = DynamicValue(self.defaultInsights)
        self.hexagonInsights = DynamicValue(self.defaultInsights.filter({ $0.insightType != .logs &&
                                                                            $0.insightType != .coughlogs }))
        SurveyTaskUtility.shared.clearSurvey()
        // HACK
        preExistingMedicalConditionData = defaultPreExistingMedicalConditionData
    }
    
    //User Attributes
    
    func fetchUserProfile() {
        UserProfileAPI.instance.getProfile { [weak self] (profile) in
            self?.userProfile.value = profile
        }
    }
    
    func checkIsDeviceConnected() {
        var healthKitConnected: Bool = false
        var appleWatchConnected: Bool = false
        
        if let device = self.healthProfile.value?.devices?[ExternalDevices.healthkit], device["connected"] == 1 {
            healthKitConnected = true
        }
        
        if let device = self.healthProfile.value?.devices?[ExternalDevices.watch], device["connected"] == 1 {
            appleWatchConnected = true
        }
        
        if healthKitConnected && appleWatchConnected {
            HealthStore.shared.getAllAuthorization()
        } else if healthKitConnected {
            HealthStore.shared.getHealthKitAuthorization(device: .applehealth) { (success) in
                
            }
        } else if appleWatchConnected {
            HealthStore.shared.getHealthKitAuthorization(device: .applewatch) { (success) in
                
            }
        }
    }
    
    func fetchUserHealthProfile() {
        UserProfileAPI.instance.getHealthProfile { [weak self] (healthProfile) in
            if healthProfile != nil {
                self?.healthProfile.value = healthProfile
            }
            self?.checkIsDeviceConnected()
        }
    }

    func fetchUserNotification() {
        let notificationAPI = NotificationAPI()
        notificationAPI.getNotification{
            [weak self] (notification) in
            if notification != nil {
                self?.userNotification.value = notification
            }
            
            //Checking ARN Satus
            DispatchQueue.main.async {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.checkARNStatus()
            }
        }
    }

    func fetchUserSubscriptions() {
        UserSubscriptionAPI.instance.getUserSubscriptions()
    }
    
    func syncUserInsights() {
        UserInsightsAPI.instance.get { [weak self] (userinsights) in
            if let insights = userinsights?.sorted(by: { $0.defaultOrder <= $1.defaultOrder }) {
                self?.userInsights.value = insights
                self?.hexagonInsights.value = insights.filter({ $0.insightType != .logs && $0.insightType != .coughlogs })
            } else if let insights = self?.defaultInsights.sorted(by: { $0.defaultOrder <= $1.defaultOrder }) {
                self?.userInsights.value = insights
                self?.hexagonInsights.value = insights.filter({ $0.insightType != .logs && $0.insightType != .coughlogs })
            }
        }
    }
    
    func updateHealthProfile(deviceName: String, connected: Int) {
        let profile = self.healthProfile.value
        if !(profile?.devices?.isEmpty ?? true) {
            if let device = profile?.devices?[deviceName] {
                self.healthProfile.value?.devices?[deviceName]?["connected"] = connected
            } else {
                self.healthProfile.value?.devices?.merge([deviceName: ["connected" : connected]]) { (current, _) in current }
            }
        } else {
            self.healthProfile.value?.devices = [deviceName:["connected": connected]]
        }
        
        UserProfileAPI.instance.saveUserHealthProfile(healthProfile: self.healthProfile.value!, completion: {
            print("Completed")
        }) { (error) in
            print("Failed to save health profile:" + error.localizedDescription)
        }
    }

    func updateHealthProfile(location:LocationDetails) {
        self.healthProfile.value?.location = location
        UserProfileAPI.instance.saveUserHealthProfile(healthProfile: self.healthProfile.value!) {
            print("updated location")
        } onFailure: { (error) in
            print("Failed to save health profile-location:" + error.localizedDescription)
        }

    }

    func updateUserNotification(enabled: Bool) {
        let localValue = self.userNotification.value?.isEnabled

        let notificationAPI = NotificationAPI()
        notificationAPI.updateNotification(userNotification: enabled, completion: { (notification) in
            self.userNotification.value = notification
        }) {
            self.userNotification.value?.isEnabled = localValue
        }
    }

    func updateUserSubscription(subscriptionType:UserSubscriptionType,
                                communicationType: CommunicationType,
                                status:Bool,
                                completion: @escaping(() -> Void)){
        if let index = self.userSubscriptions.value?.firstIndex(where: { (subscription) -> Bool in
            return subscription.subscriptionType == subscriptionType &&
                subscription.communicationType == communicationType
        }) {
            self.userSubscriptions.value?[index].status = status
        } else {
            self.userSubscriptions.value?.append(UserSubscription(subscriptionType: subscriptionType, communicationType: communicationType, status: status))
        }
        
        UserSubscriptionAPI.instance.updateUserSubscriptions(userSubscriptions:
                                                                self.userSubscriptions.value,
                                                             completion: completion)
    }

    func getAppLink() {
        UserProfileAPI.instance.getAppLink { [weak self] (appURL) in
            if let urlstring = appURL, !urlstring.isEmpty {
                self?.appShareLink = urlstring
            }
        }
    }
    
    func syncSurveyList() {
        func completion(_ surveys:[SurveyListItem]) {
            self.surveysSyncStatus.value = .completed
            
            if SurveyTaskUtility.shared.containsInprogress() {
                self.startpollingSurveys()
            } else {
                self.clearPollingTimer()
            }
        }

        func onFailure(_ error:Error) {
            self.surveysSyncStatus.value = .failed
            self.clearPollingTimer()
        }
        
        self.surveysSyncStatus.value = .inprogress
        SurveysAPI.instance.getSurveys(completion: completion(_:), onFailure: onFailure(_:))
    }
    
    var opeartionqueue: OperationQueue?

    func syncUserProfile() {
        if opeartionqueue == nil {
            opeartionqueue = OperationQueue()
            opeartionqueue?.maxConcurrentOperationCount = 2
        } else {
            opeartionqueue?.cancelAllOperations()
        }
        opeartionqueue?.addOperation {
            self.fetchUserProfile()
        }
        opeartionqueue?.addOperation {
            self.fetchUserHealthProfile()
        }
        opeartionqueue?.addOperation {
            self.fetchUserNotification()
        }
        opeartionqueue?.addOperation {
            self.fetchUserSubscriptions()
        }
        opeartionqueue?.addOperation {
            self.syncUserInsights()
        }
    }
    
    fileprivate func startpollingSurveys() {
        let queue = DispatchQueue.global(qos: .background)
        self.pollingTimer?.cancel()
        self.pollingTimer = DispatchSource.makeTimerSource(queue: queue)
        pollingTimer?.schedule(deadline: .now() + 30)
        pollingTimer?.setEventHandler(handler: {
            self.syncSurveyList()
        })
        pollingTimer?.resume()
    }
    
    fileprivate func clearPollingTimer() {
        self.pollingTimer?.cancel()
        self.pollingTimer = nil
    }
}
