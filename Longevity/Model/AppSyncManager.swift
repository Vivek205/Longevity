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
    var userNotification: DynamicValue<UserNotification>
    var userSubscriptions: DynamicValue<[UserSubscription]>
    var internetConnectionAvailable: DynamicValue<InternetConnectionState> = DynamicValue(.none)
    var surveysSyncStatus: DynamicValue<SurveySyncStatus> = DynamicValue(.notstarted)
    
    var pollingTimer: DispatchSourceTimer?
    
    fileprivate let defaultInsights = [UserInsight(name: .exposure, text: "COVID-19 Exposure",
                                userInsightDescription: "Exposure risk is how likely you have been in contact with COVID-19 infected people.",
                                defaultOrder: 0,
                                details: Details(lastLogged: nil, history: nil, riskLevel: nil, trending: nil, sentiment: nil,
                                                 confidence: Confidence(value: "",
                                                                        confidenceDescription: "How well the AI can assess your current risk situation. More check-ins and health data improves the accuracy."),
                                                 histogram: Histogram(histogramDescription: "Your COVID-19 exposure risk over the time of your check-ins."), submissions: nil),
                                isExpanded: false),
                    UserInsight(name: .risk, text: "COVID-19 Infection",
                                userInsightDescription: "Infection risk estimates your chance of having COVID-19 based on your symptoms and exposure history.",
                                defaultOrder: 1,
                                details: Details(lastLogged: nil, history: nil, riskLevel: nil, trending: nil, sentiment: nil,
                                                 confidence: Confidence(value: "",
                                                                        confidenceDescription: "How well the AI can assess your current risk situation. More check-ins and health data improves the accuracy."),
                                                 histogram: Histogram(histogramDescription: "Your COVID-19 Infection risk over the time of your check-ins."), submissions: nil),
                                isExpanded: false),
                    UserInsight(name: .distancing,
                                text: "Social Distancing",
                                userInsightDescription: "Your Social Distancing Score demonstrates whether you have practiced social distancing guidelines, wore a mask, and self-quarantined according to your local government’s instructions.",
                                defaultOrder: 2,
                                details: Details(lastLogged: nil, history: nil, riskLevel: nil, trending: nil, sentiment: nil,
                                                 confidence: Confidence(value: "",
                                                                        confidenceDescription: "How well the AI can assess your social distancing situation. More check-ins and health data improves the accuracy."),
                                                 histogram: Histogram(histogramDescription: "Your social distancing over the time of your check-ins."), submissions: nil),
                                isExpanded: false),
                    UserInsight(name: .logs,
                                text: "Results Data Log",
                                userInsightDescription: "COVID Check-in Log",
                                defaultOrder: 3,
                                details: nil,
                                isExpanded: false),
                    UserInsight(name: .coughlogs,
                                text: "Cough Test Log",
                                userInsightDescription: "Cough Test Log",
                                defaultOrder: 4,
                                details: nil,
                                isExpanded: false)]
    
    fileprivate init() {
        self.userProfile = DynamicValue(UserProfile(name: "", email: "", phone: ""))
        self.healthProfile = DynamicValue(UserHealthProfile(weight: "", height: "", gender: "", birthday: "", unit: .metric, devices: nil, preExistingConditions: nil))
        self.appShareLink = ""
        self.userNotification = DynamicValue(UserNotification(username: nil, deviceId: nil, platform: nil, endpointArn: nil, lastSent: nil, isEnabled: nil))
        self.userSubscriptions = DynamicValue([UserSubscription(subscriptionType: .longevityRelease, communicationType: .email, status: false)])
        self.userInsights = DynamicValue(self.defaultInsights)
    }
    
    func cleardata() {
        self.userProfile = DynamicValue(UserProfile(name: "", email: "", phone: ""))
        self.healthProfile = DynamicValue(UserHealthProfile(weight: "", height: "", gender: "", birthday: "", unit: .metric, devices: nil, preExistingConditions: nil))
        self.appShareLink = ""
        self.userNotification = DynamicValue(UserNotification(username: nil, deviceId: nil, platform: nil, endpointArn: nil, lastSent: nil, isEnabled: nil))
        self.userSubscriptions = DynamicValue([UserSubscription(subscriptionType: .longevityRelease, communicationType: .email, status: false)])
        self.userInsights = DynamicValue(self.defaultInsights)
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
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.getHealthProfile { [weak self] (healthProfile) in
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
            if let insights = userinsights {
                self?.userInsights.value = insights.sorted(by: { $0.defaultOrder <= $1.defaultOrder })
            } else {
                self?.userInsights.value = self?.defaultInsights
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
        
        let userProfile = UserProfileAPI()
        userProfile.saveUserHealthProfile(healthProfile: self.healthProfile.value!, completion: {
            print("Completed")
        }) { (error) in
            print("Failed to save health profile:" + error.localizedDescription)
        }
    }

    func updateHealthProfile(location:LocationDetails) {
        self.healthProfile.value?.location = location
        let userProfile = UserProfileAPI()
        userProfile.saveUserHealthProfile(healthProfile: self.healthProfile.value!) {
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

    func updateUserSubscription(subscriptionType:UserSubscriptionType, communicationType: CommunicationType, status:Bool, completion: @escaping(() -> Void)){
        if let index = self.userSubscriptions.value?.firstIndex(where: { (subscription) -> Bool in
            return subscription.subscriptionType == subscriptionType && subscription.communicationType == communicationType
        }) {
            self.userSubscriptions.value?[index].status = status
        }else {
            self.userSubscriptions.value?.append(UserSubscription(subscriptionType: subscriptionType, communicationType: communicationType, status: status))
        }
        
        UserSubscriptionAPI.instance.updateUserSubscriptions(userSubscriptions: self.userSubscriptions.value, completion: completion)
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
            
            if SurveyTaskUtility.shared.surveyInProgress.value == .pending {
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
        pollingTimer?.schedule(deadline: .now() + 60)
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
