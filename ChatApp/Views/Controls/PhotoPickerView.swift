//
//  PhotoPickerView.swift
//  ChatApp
//
//  Created by Tino on 26/1/2022.
//

import SwiftUI
import PhotosUI


struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage?]
    @Binding var isPresented: Bool
    private let filters: [PHPickerFilter]
    private let selectionLimit: Int
    
    init(selectedImages: Binding<[UIImage?]>, isPresented: Binding<Bool>, filters: [PHPickerFilter] = [.images], selectionLimit: Int = 1) {
        _selectedImages = selectedImages
        _isPresented = isPresented
        self.filters = filters
        self.selectionLimit = selectionLimit
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = PHPickerFilter.any(of: filters)
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult])
        {
            for image in results {
                if !image.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    print("Loaded asset is not an image")
                    continue
                }
                image.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let error = error as NSError? {
                        print(error)
                        return
                    }
                    DispatchQueue.main.async {
                        self.parent.selectedImages.append(image as? UIImage)
                    }
                }
            }
            parent.isPresented = false
        }
    }
}

struct PhotoPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerView(
            selectedImages: .constant([]),
            isPresented: .constant(false)
        )
    }
}
