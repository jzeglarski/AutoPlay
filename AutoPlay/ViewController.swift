//
//  ViewController.swift
//  AutoPlay
//
//  Created by John Zeglarski on 2/5/21.
//

import UIKit
import AVFoundation


let filename = "defaultVideo"
let filetype = "mp4"


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        playVideo()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    private func playVideo() {
        guard let path = Bundle.main.path(forResource: filename, ofType:filetype)
        else { fatalError("\(filename).\(filetype) not found") }
        let player = AVPlayer(url:  URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    @objc func playerDidFinishPlaying() {
        exit(0)
    }
}

