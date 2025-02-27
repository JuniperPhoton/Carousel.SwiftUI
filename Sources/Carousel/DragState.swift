//
//  DragState.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/28.
//
import Foundation

public struct DragState {
    static let inactive = DragState(isDragging: false, isEnding: false)
    
    public let isDragging: Bool
    public let isEnding: Bool
    
    public var isActive: Bool {
        isDragging || isEnding
    }
}
