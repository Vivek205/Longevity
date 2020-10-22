//
//  AppSyncManager.swift
//  Longevity
//
//  Created by Jagan Kumar Mudila on 31/08/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

class AppSyncManager  {
    static let instance = AppSyncManager()

    var userProfile: DynamicValue<UserProfile>
    var healthProfile: DynamicValue<UserHealthProfile>
    var isTermsAccepted: DynamicValue<Bool> = DynamicValue(true)
    var appShareLink: DynamicValue<String>
    var userInsights: DynamicValue<[UserInsight]>
    var userNotification: DynamicValue<UserNotification>
    var userSubscriptions: DynamicValue<[UserSubscription]>
    var internetConnectionAvailable: DynamicValue<Bool> = DynamicValue(true)
//    var userActivity: DynamicValue<UserActivity>?
    
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
                                text: "COVID Check-in Log",
                                userInsightDescription: "COVID Check-in Log",
                                defaultOrder: 3,
                                details: nil,
                                isExpanded: false)]
    
    fileprivate init() {
        self.userProfile = DynamicValue(UserProfile(name: "", email: "", phone: ""))
        self.healthProfile = DynamicValue(UserHealthProfile(weight: "", height: "", gender: "", birthday: "", unit: .metric, devices: nil, preExistingConditions: nil))
        self.appShareLink = DynamicValue("")
        self.userNotification = DynamicValue(UserNotification(username: nil, deviceId: nil, platform: nil, endpointArn: nil, lastSent: nil, isEnabled: nil))
        self.userSubscriptions = DynamicValue([UserSubscription(subscriptionType: .longevityRelease, communicationType: .email, status: false)])
//        self.userActivity = DynamicValue(UserActivity(offset: 0, limit: 50, totalActivitiesCount: 0, activities: [UserActivityDetails(title: "", username: "", activityType: .ACCOUNTCREATED, description: "", loggedAt: "", isLast: nil)]))
        self.userInsights = DynamicValue(self.defaultInsights)
    }
    //User Attributes
    
    func fetchUserProfile() {
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.getProfile { [weak self] (profile) in
            self?.userProfile.value = profile
        }
    }
    
    func fetchUserHealthProfile() {
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.getHealthProfile { [weak self] (healthProfile) in
            self?.healthProfile.value = healthProfile
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
        let userPreferenceAPI = UserSubscriptionAPI()
        userPreferenceAPI.getUserSubscriptions()
    }
    
    func checkTermsAccepted() {
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.getUserAttributes { [weak self] (termsAccepted) in
            self?.isTermsAccepted.value = termsAccepted
        }
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

//    @objc  func notificationCenterObserser(){
//        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//               switch settings.authorizationStatus {
//               case .authorized :
//                   print("Do something according to status")
//                   self.userNotification.value?.enabled = true
//               case .denied, .provisional, .notDetermined:
//                    self.userNotification.value?.enabled = false
//               }
//
//           }
//    }

    func updateUserSubscription(subscriptionType:UserSubscriptionType, communicationType: CommunicationType, status:Bool, completion: @escaping(() -> Void)){
        if let index = self.userSubscriptions.value?.firstIndex(where: { (subscription) -> Bool in
            return subscription.subscriptionType == subscriptionType && subscription.communicationType == communicationType
        }) {
            self.userSubscriptions.value?[index].status = status
        }else {
            self.userSubscriptions.value?.append(UserSubscription(subscriptionType: subscriptionType, communicationType: communicationType, status: status))
        }
        let userPreferenceAPI = UserSubscriptionAPI()
        userPreferenceAPI.updateUserSubscriptions(userSubscriptions: self.userSubscriptions.value, completion: completion)
    }

    fileprivate func getAppLink() {
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.getAppLink { [weak self] (appURL) in
            if let urlstring = appURL, !urlstring.isEmpty {
                self?.appShareLink.value = urlstring
            }
        }
    }

//    func fetchUserActivity(offset:Int = 0, limit:Int = 10, completion:((Error?) -> Void)? = nil) {
//        let userProfileAPI = UserProfileAPI()
//        userProfileAPI.getUserActivities(offset:offset, limit: limit) { (userActivity) in
//            var enhancedUserActivity = userActivity
//            if offset > 0, let currentActvities = self.userActivity?.value?.activities {
//                enhancedUserActivity.activities = currentActvities + enhancedUserActivity.activities 
//            }
//            self.userActivity?.value = enhancedUserActivity
//            completion?(nil)
//        } onFailure: { (error) in
//            print("fetchUserActivity error: - ", error)
//            completion?(error)
//        }
//
//    }

    func syncUserProfile() {
        self.fetchUserProfile()
        self.getAppLink()
        self.fetchUserHealthProfile()
        self.checkTermsAccepted()
        self.fetchUserNotification()
        self.fetchUserSubscriptions()
        AppSyncManager.instance.syncUserInsights()
    }
}
