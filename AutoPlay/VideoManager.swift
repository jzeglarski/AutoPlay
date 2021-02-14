//
//  VideoManager.swift
//  AutoPlay
//
//  Created by John Zeglarski on 2/14/21.
//

import AVKit
import Foundation

var player: AVPlayer = {
    guard let path = Bundle.main.path(forResource: filename, ofType: filetype)
    else { fatalError("\(filename).\(filetype) not found") }

    let player: AVPlayer
    if let url = videoURLFromDisk(), FileManager.default.fileExists(atPath: url.path) {
        player = AVPlayer(url: url)
    }
    else {
        player = AVPlayer(url: URL(fileURLWithPath: path))
    }
    return player
}()

func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}

func writeDataToDisk(data: Data) {
    let url = getDocumentsDirectory().appendingPathComponent("video.mp4")

    do {
        try data.write(to: url)
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        alert.dismiss(animated: true) {
            player.play()
        }
    }
    catch {
        debugPrint(error.localizedDescription)
    }
}

func videoURLFromDisk() -> URL? {
    return getDocumentsDirectory().appendingPathComponent("video.mp4")
}
