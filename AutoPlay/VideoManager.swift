//
//  VideoManager.swift
//  AutoPlay
//
//  Created by John Zeglarski on 2/14/21.
//

import Foundation

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
    } catch {
        debugPrint(error.localizedDescription)
    }
}

func videoURLFromDisk() -> URL? {
    return getDocumentsDirectory().appendingPathComponent("video.mp4")
}
