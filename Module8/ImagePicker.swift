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
    @ObservedObject var state: PhotosState
    
    var body: some View {
        if let lastImage = state.images.last(where: { _ in true }) {
            lastImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
        }
    }
}

struct ImagePicker: View {
    @StateObject var state = PhotosState()
    @State var presentPhotos = false
    @State var presentFiles = false
    @State private var isPresent = false
    @State var currentDetent: PresentationDetent = .fraction(0.3)

    var body: some View {
        VStack(spacing: 5) {
            ZStack(alignment: Alignment.topTrailing) {
                if state.images.count > 0 {
                    DisplayImageView(state: state)
                    
                } else {
                    Color.white
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                state.images.count > 1 ?
                    Button(action: {
                        isPresent.toggle()
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
        .sheet(isPresented: $isPresent) {
            if currentDetent == .fraction(0.3) {
                SheetViewSmall(state: state)
                    .presentationDetents([.fraction(0.3), .large], selection: $currentDetent)
            }
            else {
                SheetViewLarge(state: state)
                    .presentationDetents([.fraction(0.3), .large], selection: $currentDetent)
            }
        }
        
        
    }
    
    struct SheetViewSmall: View {
        @Environment(\.dismiss) var dismiss
        @ObservedObject var state: PhotosState
        
        var body: some View {
            Color.green
                .overlay(
                    HStack {
                        ForEach(state.images.indices, id: \.self) { index in
                            state.images[index]
                                .resizable()
                                .aspectRatio( contentMode: .fit)
                        }
                    }
                )
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
        }
    }
    
    struct SheetViewLarge: View {
        @Environment(\.dismiss) var dismiss
        @ObservedObject var state: PhotosState
        
        var body: some View {
            Color.green
                .overlay(
                    VStack {
                        ForEach(state.images.indices, id: \.self) { index in
                            state.images[index]
                                .resizable()
//                                .frame(width: 150, height: 150)
                                .aspectRatio( contentMode: .fit)
                                .overlay(
                                    Button(action: {
                                        if index >= 0 && index < state.images.count {
                                            state.images.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 50))
                                    }
                                )
                        }.padding(5)
                    }
                )
                .ignoresSafeArea()
                .onChange(of: state.images.count, perform: { count in
                    if count == 0 {
                        dismiss()
                    }
                })
                .onTapGesture {
                    dismiss()
                }
        }
    }
}

#Preview {
    ImagePicker()
}
