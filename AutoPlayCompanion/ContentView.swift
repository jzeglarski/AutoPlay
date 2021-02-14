//
//  ContentView.swift
//  AutoPlayCompanion
//
//  Created by John Zeglarski on 2/13/21.
//

import AVKit
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

    @ObservedObject var connector = ConnectivityManager()
    @State private var showingImagePicker = false
    @State private var inputVideoURL: URL?

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
                Form {
                    Section(header: Text("Devices")) {
                        if connector.peers.count > 0 {
                            deviceStack
                        }
                        else {
                            noDevices
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            Image("Header")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: headerSize.width, height: headerSize.height)
                .padding(.top, headerSize.height * 0.4)
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            VideoPicker(videoURL: self.$inputVideoURL)
        }
        .onDisappear(perform: {
            connector.stopBrowsing()
            connector.endSession()
        })
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

    var noDevices: some View {
        Button(action: { }, label: {
            ZStack(alignment: .leading) {
                Image(systemName: "iphone.slash")
                    .imageScale(.large)
                HStack {
                    Spacer()
                    Text("No Devices")
                    Spacer()
                }
            }
        })
            .font(Font.system(size: 18, weight: .medium, design: .default))
            .foregroundColor(.secondary)
            .cornerRadius(12)
    }

    var deviceStack: some View {
        ForEach(connector.peers, id: \.displayName) { peer in
            Button(action: { connector.invite(peer: peer) }, label: {
                ZStack(alignment: .leading) {
                    Image(systemName: connector.connectedPeers.contains(peer) ? "appletv.fill" : "appletv")
                        .imageScale(.large)
                    HStack {
                        Spacer()
                        Text(peer.displayName)
                        Spacer()
                    }
                }
            })
                .font(Font.system(size: 18, weight: .medium, design: .default))
                .cornerRadius(12)
                .foregroundColor(connector.connectedPeers.contains(peer) ? .green : .primary)
                .disabled(connector.connectedPeers.contains(peer))
        }
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
                connector.sendVideo(url: inputVideoURL)
            }, label: {
                Image(systemName: "square.and.arrow.up")
                Text("Uplaod")
            })
                .frame(maxWidth: size.width)
                .padding(.vertical)
                .background(Color.accentColor)
                .cornerRadius(12)
                .disabled(connector.connectedPeers.count < 1)
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: size.width)
    }

    func loadImage() {
        guard let videoURL = inputVideoURL else { return }
        player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
        player.play()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
