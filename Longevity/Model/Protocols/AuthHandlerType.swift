//
//  AuthHandlerType.swift
//  Longevity
//
//  Created by vivek on 30/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import SafariServices
import AuthenticationServices

typealias AuthHandlerCompletion = (URL?, Error?) -> Void

class AuthContextProvider: NSObject {

    private weak var anchor: ASPresentationAnchor!

    init(_ anchor: ASPresentationAnchor) {
        self.anchor = anchor
    }

}

extension AuthContextProvider: ASWebAuthenticationPresentationContextProviding {

    @available(iOS 12.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return anchor
    }

}

protocol AuthHandlerType: class {
    var session: NSObject? { get set }
    var contextProvider: AuthContextProvider? { get set }
    func auth(url: URL, callbackScheme: String, completion: @escaping AuthHandlerCompletion)
}

extension AuthHandlerType {

    func auth(url: URL, callbackScheme: String, completion: @escaping AuthHandlerCompletion) {
        if #available(iOS 12, *) {
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) {
                url, error in
                completion(url, error)
            }
            if #available(iOS 13.0, *) {
                session.presentationContextProvider = contextProvider
            } else {
                // Fallback on earlier versions
            }
            session.start()
            self.session = session
        } else {
            let session = SFAuthenticationSession(url: url, callbackURLScheme: callbackScheme) {
                url, error in
                completion(url, error)
            }
            session.start()
            self.session = session
        }
    }

}
