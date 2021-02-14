//
//  ViewController.swift
//  AutoPlay
//
//  Created by John Zeglarski on 2/5/21.
//

import UIKit
import AVFoundation
import MultipeerConnectivity


let filename = "defaultVideo"
let filetype = "mp4"


class ViewController: UIViewController {
    
    lazy var player: AVPlayer = {
        guard let path = Bundle.main.path(forResource: filename, ofType:filetype)
        else { fatalError("\(filename).\(filetype) not found") }
        
        if let url = videoURLFromDisk(), FileManager.default.fileExists(atPath: url.path) {
            return AVPlayer(url: url)
        }
        
        return AVPlayer(url: URL(fileURLWithPath: path))
    }()
    
    lazy var connector = ConnectivityManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(connectCompanion))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)
    }

    func playVideo() {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    @objc func connectCompanion() {
        player.pause()
        connector.startAdvertising()
        debugPrint("Begin Advertising...")
        
        let alert = UIAlertController(title: "Connecting", message: "Open the AutoPlay app on iPhone to connect.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
            self.connector.stopAdvertising()
            self.player.play()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func playerDidFinishPlaying() {
        connector.stopAdvertising()
        connector.endSession()
        exit(0)
    }
}
