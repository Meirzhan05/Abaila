//
//  MediaItem.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 8/8/25.
//
import SwiftUI
import PhotosUI
struct MediaItem: Identifiable {
    let id = UUID()
    let image: Image?
    let isVideo: Bool
    let originalItem: PhotosPickerItem
}
