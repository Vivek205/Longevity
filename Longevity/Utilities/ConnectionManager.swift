//
//  ConnectionManager.swift
//  Longevity
//
//  Created by vivek on 15/10/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import Reachability

final class ConnectionManager {
    static let instance = ConnectionManager()
    private var reachability : Reachability!

    func observeReachability(){
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            self.reachability = try Reachability()
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }

    @objc func reachabilityChanged(note: Notification) {
        guard  let reachability = note.object as? Reachability else { return }
        switch reachability.connection {
        case .cellular:
            print("Cellular")
        case .wifi:
            print("Wifi")
        case .none:
            print("none")
        case .unavailable:
            print("unavailable")
        }

        print("isConnected", reachability)
    }
}
