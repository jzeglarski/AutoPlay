//
//  ContentView.swift
//  AutoPlayCompanion
//
//  Created by John Zeglarski on 2/13/21.
//

import AVKit
import CoreData
import MultipeerConnectivity
import SwiftUI

let filename = "defaultVideo"
let filetype = "mp4"

var player: AVPlayer = {
    guard let path = Bundle.main.path(forResource: filename, ofType: filetype)
    else { fatalError("\(filename).\(filetype) not found") }
    return AVPlayer(url: URL(fileURLWithPath: path))
}()

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(entity: Video.entity(), sortDescriptors: []) var videos: FetchedResults<Video>

    @State private var showingImagePicker = false
    @State private var inputVideoURL: URL?
    @State private var videoWasImported = false

    var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width - 40,
               height: (UIScreen.main.bounds.width - 40) * (9 / 16))
    }

    var headerSize: CGSize {
        CGSize(width: UIScreen.main.bounds.width * 0.8,
               height: UIScreen.main.bounds.width * (1 / 3))
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer(minLength: headerSize.height * 1.4).fixedSize()
                videoPlayer
                actionStack
                Spacer()
            }
            Image("Header")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: headerSize.width, height: headerSize.height)
                .padding(.top, headerSize.height * 0.4)
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadVideo) {
            VideoPicker(videoURL: self.$inputVideoURL)
        }
    }

    var videoPlayer: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.play()
            }
            .onDisappear {
                player.pause()
            }
            .aspectRatio(16 / 9, contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .cornerRadius(12)
    }

    var actionStack: some View {
        HStack(spacing: 8) {

            Button(action: {
                self.showingImagePicker = true
            }, label: {
                Image(systemName: "photo.fill.on.rectangle.fill")
                Text("Pick Video")
            })
                .frame(maxWidth: size.width)
                .padding(.vertical)
                .background(Color.accentColor)
                .cornerRadius(12)

            Button(action: {
                saveVideo()
            }, label: {
                Image(systemName: videoWasImported ?
                    "icloud.and.arrow.up" :
                    "checkmark.icloud")
                Text(videoWasImported ? "Upload" : "Ready")
            })
                .frame(maxWidth: size.width)
                .padding(.vertical)
                .background(Color.accentColor)
                .cornerRadius(12)
                .disabled(!videoWasImported)
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: size.width)
    }

    func loadVideo() {
        guard
            let videoURL = inputVideoURL
        else { return }
        
        do {
            let video = videos.first ?? Video(context: viewContext)
            video.data = try Data(contentsOf: videoURL, options: .mappedIfSafe)
            videoWasImported = viewContext.hasChanges
            player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
            player.play()
        }
        catch {
            debugPrint(error)
        }
    }

    func saveVideo() {
        try? viewContext.save()
        videoWasImported = viewContext.hasChanges
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
