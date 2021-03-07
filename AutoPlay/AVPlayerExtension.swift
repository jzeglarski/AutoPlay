//
//  AVPlayerExtension.swift
//  AutoPlay
//
//  Created by John Zeglarski on 3/6/21.
//

import AVFoundation
import UIKit

extension AVPlayer {

    convenience init(data: Data) {

        if  let urlString = String(data: data, encoding: .utf8) {
            self.init(url: URL(string: urlString)!)

        } else {
            self.init()
        }

    }

    class func thumbNail (videoURL:URL) -> UIImage? {
        var imgRef:CGImage? = nil
        let asset = AVURLAsset(url: videoURL)
        let generate = AVAssetImageGenerator(asset: asset)
        generate.appliesPreferredTrackTransform = true

        let time = CMTimeMake(value: 1, timescale: 60);

        do {

            imgRef = try generate.copyCGImage(at: time, actualTime: nil)

        } catch let e as NSError {
            print(e.localizedDescription)
        }

        if imgRef != nil {
            return UIImage(cgImage: imgRef!)
        } else {
            return nil
        }
    }
}
