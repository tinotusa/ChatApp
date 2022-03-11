//
//  URLDropDelegate.swift
//  ChatApp
//
//  Created by Tino on 27/1/2022.
//

import SwiftUI

struct URLDropDelegate: DropDelegate {
    @Binding var image: UIImage?
    
    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [.url]) else {
            return false
        }
        
        let items = info.itemProviders(for: [.url])
        for item in items {
            _ = item.loadObject(ofClass: URL.self) { url, error in
                if error != nil {
                    print("Error in \(#function)\n\(error!)")
                    return
                }
                guard let url = url else {
                    print("Error in \(#function): url is nil")
                    return
                }
                do {
                    let imageData = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.image = UIImage(data: imageData)
                    }
                } catch {
                    print("Error in \(#function): Failed to get image data from url\n\(error)")
                }
            }
        }
        return true
    }
}
