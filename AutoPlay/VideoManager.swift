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
            //writeDataToDisk(data: video)
            player = AVPlayer(data: video)
        }
        else {
            print("No video to write")
            debugPrint("VIDEOS", videos)
            
            if let url = videoURLFromDisk(), FileManager.default.fileExists(atPath: url.path) {
                print("Loaded video from disk")
                player = AVPlayer(url: url)
            }
            else {
                print("Loaded default video. missig video on disk")
                player = AVPlayer(url: URL(fileURLWithPath: path))
            }
        }
    }
    catch {
        debugPrint(error)
        print("Loaded default video from crash")
        player = AVPlayer(url: URL(fileURLWithPath: path))
    }

    return player
}()

func replacePlayerItem() {
    guard let path = Bundle.main.path(forResource: filename, ofType: filetype)
    else { fatalError("\(filename).\(filetype) not found") }

    do {
        let persistanceController = PersistenceController.shared
        let videos = try persistanceController.container.viewContext.fetch(Video.fetchRequest()) as [Video]
        if let video = videos.first?.data {
            print("Writing video to disk")
            writeDataToDisk(data: video)
        }
        else {
            print("No video to write")
            debugPrint("VIDEOS", videos)
        }
        
        if let url = videoURLFromDisk(), FileManager.default.fileExists(atPath: url.path) {
            print("Loaded video from disk")
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        else {
            print("Loaded default video. missig video on disk")
            player.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: path)))
        }
    }
    catch {
        debugPrint(error)
        print("Loaded default video from crash")
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: path)))
    }
}

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
