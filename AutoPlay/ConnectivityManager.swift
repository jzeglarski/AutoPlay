//
//  ConnectivityManager.swift
//  AutoPlay
//
//  Created by John Zeglarski on 2/13/21.
//

import Foundation
import MultipeerConnectivity
import AVFoundation

class ConnectivityManager: NSObject {
    
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser

    override init() {
        session = MCSession( peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: "autoplay-cnct")
        super.init()
        advertiser.delegate = self
        session.delegate = self
    }
    
    func startAdvertising() {
        advertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        advertiser.stopAdvertisingPeer()
    }
    
    func endSession() {
        session.disconnect()
    }
    
}

extension ConnectivityManager: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        debugPrint("Received invitation from \(peerID.displayName)")
        invitationHandler(true, self.session)
    }
    
}

extension ConnectivityManager: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        debugPrint("session did change to \(state.rawValue) with \(peerID.displayName)")
        switch state {
        case .connecting: break
        case .connected: break
        case .notConnected: break
        default: break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        debugPrint("session did receive data from \(peerID.displayName)")
        writeDataToDisk(data: data)
        
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

