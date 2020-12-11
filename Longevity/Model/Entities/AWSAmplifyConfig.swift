//
//  AWSAmplifyConfig.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import Foundation

// MARK: - AWSAmplifyConfig
struct AWSAmplifyConfig: Codable {
    let userAgent, version: String
    let auth: Auth
    let api: API

    enum CodingKeys: String, CodingKey {
        case userAgent = "UserAgent"
        case version = "Version"
        case auth, api
    }
}

// MARK: - API
struct API: Codable {
    let plugins: APIPlugins
}

// MARK: - APIPlugins
struct APIPlugins: Codable {
    let awsAPIPlugin: AwsAPIPlugin
}

// MARK: - AwsAPIPlugin
struct AwsAPIPlugin: Codable {
    let rejuveDevelopmentAPI, mockQuestionsAPI, surveyAPI, insightsAPI: InsightsAPIClass
}

// MARK: - InsightsAPIClass
struct InsightsAPIClass: Codable {
    let endpointType, endpoint, region, authorizationType: String
}

// MARK: - Auth
struct Auth: Codable {
    let plugins: AuthPlugins
}

// MARK: - AuthPlugins
struct AuthPlugins: Codable {
    let awsCognitoAuthPlugin: AwsCognitoAuthPlugin
}

// MARK: - AwsCognitoAuthPlugin
struct AwsCognitoAuthPlugin: Codable {
    let userAgent, version: String
    let identityManager: IdentityManager
    let credentialsProvider: CredentialsProvider
    let cognitoUserPool: CognitoUserPool
    let googleSignIn: GoogleSignIn
    let facebookSignIn: FacebookSignIn
    let auth: AuthClass

    enum CodingKeys: String, CodingKey {
        case userAgent = "UserAgent"
        case version = "Version"
        case identityManager = "IdentityManager"
        case credentialsProvider = "CredentialsProvider"
        case cognitoUserPool = "CognitoUserPool"
        case googleSignIn = "GoogleSignIn"
        case facebookSignIn = "FacebookSignIn"
        case auth = "Auth"
    }
}

// MARK: - AuthClass
struct AuthClass: Codable {
    let authDefault: AuthDefault

    enum CodingKeys: String, CodingKey {
        case authDefault = "Default"
    }
}

// MARK: - AuthDefault
struct AuthDefault: Codable {
    let oAuth: OAuth
    let authenticationFlowType: String

    enum CodingKeys: String, CodingKey {
        case oAuth = "OAuth"
        case authenticationFlowType
    }
}

// MARK: - OAuth
struct OAuth: Codable {
    let webDomain, appClientID, appClientSecret, signInRedirectURI: String
    let signOutRedirectURI: String
    let scopes: [String]

    enum CodingKeys: String, CodingKey {
        case webDomain = "WebDomain"
        case appClientID = "AppClientId"
        case appClientSecret = "AppClientSecret"
        case signInRedirectURI = "SignInRedirectURI"
        case signOutRedirectURI = "SignOutRedirectURI"
        case scopes = "Scopes"
    }
}

// MARK: - CognitoUserPool
struct CognitoUserPool: Codable {
    let cognitoUserPoolDefault: CognitoUserPoolDefault

    enum CodingKeys: String, CodingKey {
        case cognitoUserPoolDefault = "Default"
    }
}

// MARK: - CognitoUserPoolDefault
struct CognitoUserPoolDefault: Codable {
    let poolID, appClientID, appClientSecret, region: String

    enum CodingKeys: String, CodingKey {
        case poolID = "PoolId"
        case appClientID = "AppClientId"
        case appClientSecret = "AppClientSecret"
        case region = "Region"
    }
}

// MARK: - CredentialsProvider
struct CredentialsProvider: Codable {
    let cognitoIdentity: CognitoIdentity

    enum CodingKeys: String, CodingKey {
        case cognitoIdentity = "CognitoIdentity"
    }
}

// MARK: - CognitoIdentity
struct CognitoIdentity: Codable {
    let cognitoIdentityDefault: CognitoIdentityDefault

    enum CodingKeys: String, CodingKey {
        case cognitoIdentityDefault = "Default"
    }
}

// MARK: - CognitoIdentityDefault
struct CognitoIdentityDefault: Codable {
    let poolID, region: String

    enum CodingKeys: String, CodingKey {
        case poolID = "PoolId"
        case region = "Region"
    }
}

// MARK: - FacebookSignIn
struct FacebookSignIn: Codable {
    let appID, permissions: String

    enum CodingKeys: String, CodingKey {
        case appID = "AppId"
        case permissions = "Permissions"
    }
}

// MARK: - GoogleSignIn
struct GoogleSignIn: Codable {
    let permissions, clientIDWebApp, clientIDIOS: String

    enum CodingKeys: String, CodingKey {
        case permissions = "Permissions"
        case clientIDWebApp = "ClientId-WebApp"
        case clientIDIOS = "ClientId-iOS"
    }
}

// MARK: - IdentityManager
struct IdentityManager: Codable {
    let identityManagerDefault: IdentityManagerDefault

    enum CodingKeys: String, CodingKey {
        case identityManagerDefault = "Default"
    }
}

// MARK: - IdentityManagerDefault
struct IdentityManagerDefault: Codable {
}
