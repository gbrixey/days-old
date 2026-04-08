//
//  WatchHelper.swift
//  DaysOld
//
//  Created by Glen Brixey on 4/4/26.
//

import WatchConnectivity

class WatchHelper: NSObject {

    static let shared: WatchHelperProtocol = WatchHelper()
}

// MARK: - WatchHelperProtocol

protocol WatchHelperProtocol: WCSessionDelegate {
    func requestWatchUpdate() async -> Date?
    func updateWatch()
}

extension WatchHelper: WatchHelperProtocol {

    func requestWatchUpdate() async -> Date? {
        await withCheckedContinuation { continuation in
            let message = [WatchMessageKey.requestWatchUpdate: true]
            WCSession.default.sendMessage(message as [String: Any]) { reply in
                let birthdate = reply[WatchMessageKey.birthdate] as? Date
                continuation.resume(returning: birthdate)
            } errorHandler: { _ in
                continuation.resume(returning: nil)
            }
        }
    }

    func updateWatch() {
        let birthdate = KeychainHelper.shared.fetchBirthdate()
        let message = [WatchMessageKey.birthdate: birthdate]
        WCSession.default.sendMessage(message as [String: Any], replyHandler: nil)
    }
}

// MARK: - WCSessionDelegate

extension WatchHelper: WCSessionDelegate {

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: (any Error)?) {
        // No-op
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        // No-op
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
#endif

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let birthdate = message[WatchMessageKey.birthdate] as? Date? else { return }
        NotificationCenter.default.post(name: .receivedBirthdateUpdate, object: birthdate)
    }

    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        guard let didRequestUpdate = message[WatchMessageKey.requestWatchUpdate] as? Bool, didRequestUpdate else { return }
        let birthdate = KeychainHelper.shared.fetchBirthdate()
        replyHandler([WatchMessageKey.birthdate: birthdate as Any])
    }
}

// MARK: - TestWatchHelper

class TestWatchHelper: NSObject, WatchHelperProtocol {

    var birthdate: Date?

    func requestWatchUpdate() async -> Date? {
        return birthdate
    }
    
    func updateWatch() {
        NotificationCenter.default.post(name: .receivedBirthdateUpdate, object: birthdate)
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: (any Error)?) {
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }
#endif
}
