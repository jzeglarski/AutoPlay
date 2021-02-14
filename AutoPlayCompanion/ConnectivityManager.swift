//
//  ConnectivityManager.swift
//  AutoPlayCompanion
//
//  Created by John Zeglarski on 2/13/21.
//

import Foundation
import MultipeerConnectivity

class ConnectivityManager: NSObject, ObservableObject {

    @Published var peers: [MCPeerID] = []
    @Published var connectedPeers: [MCPeerID] = []

    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let session: MCSession
    private let browser: MCNearbyServiceBrowser

    override init() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: "autoplay-cnct")
        super.init()
        browser.delegate = self
        session.delegate = self
        startBrowsing()
    }

    deinit {
        stopBrowsing()
    }

    func startBrowsing() {
        debugPrint("Browsing for peers")
        browser.startBrowsingForPeers()
    }

    func stopBrowsing() {
        debugPrint("Browsing for peers ended")
        browser.stopBrowsingForPeers()
    }

    func endSession() {
        session.disconnect()
    }

    func invite(peer peerID: MCPeerID) {
        debugPrint("Inviting Peer \(peerID.displayName)")
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 60)
    }

    func sendVideo(url: URL?) {
        guard
            let url = url,
            let video = try? Data(contentsOf: url, options: .mappedIfSafe)
        else { return }
        try? session.send(video, toPeers: session.connectedPeers, with: .reliable)
    }
}

extension ConnectivityManager: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        debugPrint(error.localizedDescription)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        if !peers.contains(peerID) {
            peers.append(peerID)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = peers.firstIndex(of: peerID) {
            peers.remove(at: index)
        }
    }
}

extension ConnectivityManager: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        debugPrint("session did change to \(state.rawValue) with \(peerID.displayName)")
        DispatchQueue.main.async { [self] in
            switch state {
            case .connected:
                if !connectedPeers.contains(peerID) {
                    connectedPeers.append(peerID)
                }
            case .notConnected:
                if let index = connectedPeers.firstIndex(of: peerID) {
                    connectedPeers.remove(at: index)
                }
            default: break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        debugPrint("session did receive data from \(peerID.displayName)")
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        debugPrint("session did receive stream from \(peerID.displayName)")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        debugPrint("session did begin receiving data from \(peerID.displayName)")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        debugPrint("session did finish receiving data from \(peerID.displayName)")
    }
}
