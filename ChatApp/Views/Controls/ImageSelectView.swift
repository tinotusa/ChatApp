//
//  ImageSelectView.swift
//  ChatApp
//
//  Created by Tino on 26/1/2022.
//

import SwiftUI
import PhotosUI

struct ImageSelectView: View {
    @Binding var selectedImages: [UIImage?]
    @State private var showingPhotoPicker = false
    private let filters: [PHPickerFilter]
    private let selectionLimit: Int
    
    init(selectedImages: Binding<[UIImage?]>, filters: [PHPickerFilter] = [.images], selectionLimit: Int = 1) {
        _selectedImages = selectedImages
        self.filters = filters
        self.selectionLimit = selectionLimit
    }
    
    var body: some View {
        ZStack {
            if selectedImages.isEmpty {
                Rectangle()
                    .foregroundColor(.gray)
                VStack {
                    Text("Tap to select an image.")
                    Text("Or drag and drop an image url")
                }
                .foregroundColor(.white)
            } else {
                if let image = selectedImages.first! {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .stroke(style: StrokeStyle(lineWidth: 4, dash: [15.0]))
                .foregroundColor(Color("primaryColour"))
        }
//        .onDrop(of: [.url], delegate: URLDropDelegate(image: $selectedImage))
        .onTapGesture {
            showingPhotoPicker = true
        }
        .popover(isPresented: $showingPhotoPicker) {
            PhotoPickerView(
                selectedImages: $selectedImages,
                isPresented: $showingPhotoPicker,
                filters: filters,
                selectionLimit: selectionLimit
            )
        }
    }
}

struct ImageSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSelectView(selectedImages: .constant([UIImage()]))
    }
}
