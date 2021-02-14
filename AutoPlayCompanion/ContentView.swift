//
//  ContentView.swift
//  AutoPlayCompanion
//
//  Created by John Zeglarski on 2/13/21.
//

import SwiftUI
import AVKit
import MultipeerConnectivity

let filename = "defaultVideo"
let filetype = "mp4"

var player: AVPlayer = {
    guard let path = Bundle.main.path(forResource: filename, ofType:filetype)
    else { fatalError("\(filename).\(filetype) not found") }
    return AVPlayer(url:  URL(fileURLWithPath: path))
}()

struct ContentView: View {
    
    @ObservedObject var connector = ConnectivityManager()
    @State private var showingImagePicker = false
    @State private var inputVideoURL: URL?
    
    var size: CGSize {
        CGSize(width: UIScreen.main.bounds.width - 40,
               height: (UIScreen.main.bounds.width - 40) * (9/16))
    }
    
    var headerSize: CGSize {
        CGSize(width: UIScreen.main.bounds.width,
               height: (UIScreen.main.bounds.width) * (1/3))
    }
        
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Spacer(minLength: headerSize.height + 30).fixedSize()
                videoPlayer
                actionStack
                Form {
                    Section(header: Text("Devices")) {
                        peerStack
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            Image("Header")
                .resizable()
                .frame(width: headerSize.width, height: headerSize.height)
                .padding(.top, 30)
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
            .onAppear() {
                player.play()
            }
            .onDisappear() {
                player.pause()
            }
            .aspectRatio((16/9), contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .cornerRadius(12)
    }
    
    var noDevices: some View {
        Button(action: { }, label: {
            ZStack(alignment: .leading) {
                Image(systemName: "appletv")
                    .imageScale(.large)
                HStack {
                    Spacer()
                    Text("No Devices")
                        .font(.headline)
                        .padding(.vertical)
                    Spacer()
                }
            }
        })
        .cornerRadius(12)
    }
    
    var peerStack: some View {
        ForEach(connector.peers, id: \.displayName) { peer in
            Button(action: { connector.invite(peer: peer) }, label: {
                ZStack(alignment: .leading) {
                    Image(systemName: "appletv")
                        .imageScale(.large)
                        .padding(.leading)
                    HStack {
                        Spacer()
                        Text(peer.displayName)
                            .font(.headline)
                            .padding(.vertical)
                        Spacer()
                    }
                }
            })
            .foregroundColor(.white)
            .frame(maxWidth:size.width)
            .background(Color.black)
            .cornerRadius(12)
        }
        .padding(.vertical)
    }
    
    var actionStack: some View {
        HStack(spacing: 8) {
            
            Button(action: {
                self.showingImagePicker = true
            }, label: {
                Image(systemName: "photo.fill.on.rectangle.fill")
                Text("Pick Video")
            })
            .frame(maxWidth:size.width)
            .padding(.vertical)
            .background(Color.accentColor)
            .cornerRadius(12)
            
            Button(action: uploadVideo, label: {
                Image(systemName: "square.and.arrow.up")
                Text("Uplaod")
            })
            .frame(maxWidth:size.width)
            .padding(.vertical)
            .background(Color.accentColor)
            .cornerRadius(12)
            .disabled(!connector.isConnected)
            
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: size.width)
    }
    
    func uploadVideo() {
        connector.sendVideo(url: inputVideoURL)
    }
    
    func loadImage() {
        guard let videoURL = inputVideoURL else { return }
        debugPrint(videoURL.debugDescription)
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
