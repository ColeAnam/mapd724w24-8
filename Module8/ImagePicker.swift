//
//  ImagePicker.swift
//  Module8
//
//  Created by Cenk Bilgen on 2024-03-08.
//

import SwiftUI
import PhotosUI

class PhotosState: ObservableObject {
    @Published var photoItem: PhotosPickerItem? {
        didSet {
            print("Photo Selected \(photoItem.debugDescription)")
            photoItem?.loadTransferable(type: Image.self) { result in
                switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(let image):
                    self.images.append(image!)
                }
            }
        }
    }

    @Published var fileURL: URL?

    @Published var images: [Image] = []

}

struct DisplayImageView: View {
    @ObservedObject var state: PhotosState {
        didSet {
            
        }
    }
    
    var body: some View {
        ZStack(alignment: Alignment.topTrailing) {
            if let lastImage = state.images.last(where: { _ in true }) {
                lastImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .ignoresSafeArea()
            }
            
            state.images.count > 1 ?
                Button(action: {
                    
                }, label: {
                    Color.white
                        .overlay(Text("History"))
                })
                .frame(width: 100, height: 60)
                .alignmentGuide(HorizontalAlignment.trailing) { _ in
                    return UIScreen.main.bounds.width - 170
                }
            : nil
        }
    }
}

struct ImagePicker: View {
    @StateObject var state = PhotosState()
    @State var presentPhotos = false
    @State var presentFiles = false

    var body: some View {
        VStack(spacing: 5) {
            if state.images.count > 0 {
                DisplayImageView(state: state)
            } else {
                Color.white
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
                
                    
                

            HStack(spacing: 5) {
                Button {
                    presentPhotos = true
                } label: {
                    Color.red
                        .overlay(Text("Get Photo"))
                }

                Button {
                    presentFiles = true
                } label: {
                    Color.yellow
                        .overlay(Text("Get File"))
                }
            }
            .foregroundColor(.primary)
        }
        .photosPicker(isPresented: $presentPhotos, selection: $state.photoItem, matching: .images, preferredItemEncoding: .compatible)
        .fileImporter(isPresented: $presentFiles, allowedContentTypes: [.image]) { result in
            switch result {
                case .success(let url):
                    state.fileURL = url
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ImagePicker()
}
