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
    var isTermsAccepted: DynamicValue<Bool>
    var appShareLink: DynamicValue<String>
    var userInsights: DynamicValue<[UserInsight]>
    var userNotification: DynamicValue<UserNotification>
    var userSubscriptions: DynamicValue<[UserSubscription]>
    
    fileprivate init() {
        self.userProfile = DynamicValue(UserProfile(name: "", email: "", phone: ""))
        self.healthProfile = DynamicValue(UserHealthProfile(weight: "", height: "", gender: "", birthday: "", unit: .metric, devices: nil, preconditions: nil))
        self.isTermsAccepted = DynamicValue(true)
        self.appShareLink = DynamicValue("")
        self.userNotification = DynamicValue(UserNotification(username: nil, deviceId: nil, platform: nil, endpointArn: nil, lastSent: nil, isEnabled: nil))
        self.userSubscriptions = DynamicValue([UserSubscription(subscriptionType: .longevityRelease, communicationType: .email, status: false)])
        
        let insights = [UserInsight(name: .exposure, text: "COVID-19 Exposure", userInsightDescription: "COVID-19 Exposure", defaultOrder: 0, details: nil, isExpanded: false),
                        UserInsight(name: .risk, text: "COVID-19 Infection", userInsightDescription: "COVID-19 Infection", defaultOrder: 1, details: nil, isExpanded: false),
                        UserInsight(name: .distancing, text: "Social Distancing", userInsightDescription: "Social Distancing", defaultOrder: 2, details: nil, isExpanded: false),
                        UserInsight(name: .logs, text: "COVID Check-in Log", userInsightDescription: "COVID Check-in Log", defaultOrder: 3, details: nil, isExpanded: false)]
        self.userInsights = DynamicValue(insights)

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
            self?.userNotification.value = notification
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
        UserInsightsAPI.instance.get { [weak self] (insights) in
            if let insights = insights {
                self?.userInsights.value = insights.sorted(by: { $0.defaultOrder <= $1.defaultOrder })
            }
        }
    }
    
    func updateHealthProfile(deviceName: String, connected: Int) {
        let profile = self.healthProfile.value
        if let devices = profile?.devices {
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

    func updateUserNotification(enabled: Bool) {
        let localValue = self.userNotification.value?.isEnabled
        self.userNotification.value?.isEnabled = enabled

        let notificationAPI = NotificationAPI()
        notificationAPI.updateNotification(completion: { (notification) in
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

    func updateUserSubscription(subscriptionType:UserSubscriptionType, communicationType: CommunicationType, status:Bool){
        if let index = self.userSubscriptions.value?.firstIndex(where: { (subscription) -> Bool in
            return subscription.subscriptionType == subscriptionType && subscription.communicationType == communicationType
        }) {
            self.userSubscriptions.value?[index].status = status
        }else {
            self.userSubscriptions.value?.append(UserSubscription(subscriptionType: subscriptionType, communicationType: communicationType, status: status))
        }
        let userPreferenceAPI = UserSubscriptionAPI()
        userPreferenceAPI.updateUserSubscriptions(userSubscriptions: self.userSubscriptions.value)
    }

    fileprivate func getAppLink() {
        let userProfileAPI = UserProfileAPI()
        userProfileAPI.getAppLink { [weak self] (appURL) in
            if let urlstring = appURL, !urlstring.isEmpty {
                self?.appShareLink.value = urlstring
            }
        }
    }
    
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
