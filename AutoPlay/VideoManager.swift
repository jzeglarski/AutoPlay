//
//  VideoManager.swift
//  AutoPlay
//
//  Created by John Zeglarski on 2/14/21.
//

import AVKit
import CoreData
import Foundation

let filename = "defaultVideo"
let filetype = "mp4"

var player: AVPlayer = {
    guard let path = Bundle.main.path(forResource: filename, ofType: filetype)
    else { fatalError("\(filename).\(filetype) not found") }

    let player: AVPlayer

    do {
        let persistanceController = PersistenceController.shared
        let videos = try persistanceController.container.viewContext.fetch(Video.fetchRequest()) as [Video]
        if let video = videos.first?.data {
            print("Playing video from data")
            let playerItem = CachingPlayerItem(data: video, mimeType: "video/mp4", fileExtension: filetype)
            player = AVPlayer(playerItem: playerItem)
        }
        else {
            print("No video data")
            debugPrint("VIDEOS", videos)
            player = AVPlayer(url: URL(fileURLWithPath: path))
        }
    }
    catch {
        debugPrint(error)
        print("Loaded default video from crash")
        player = AVPlayer(url: URL(fileURLWithPath: path))
    }

    return player
}()
