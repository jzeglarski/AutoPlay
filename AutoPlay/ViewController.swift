//
//  ViewController.swift
//  AutoPlay
//
//  Created by John Zeglarski on 2/5/21.
//

import AVFoundation
import MultipeerConnectivity
import UIKit

/*
var alert: UIAlertController = {
    let alert = UIAlertController(title: "Waiting for iPhone", message: "Open the AutoPlay app on iPhone to connect and upload videos.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        connector.stopAdvertising()
        player.play()
    }))
    return alert
}()
*/

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(connectCompanion))
//        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue)]
//        view.addGestureRecognizer(tapRecognizer)
    }

    func playVideo() {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        player.play()
    }

    /*
    @objc func connectCompanion() {
        player.pause()
        connector.startAdvertising()
        present(alert, animated: true, completion: nil)
    }
    */

    @objc func playerDidFinishPlaying() {
//        connector.stopAdvertising()
//        connector.endSession()
        exit(0)
    }
}
