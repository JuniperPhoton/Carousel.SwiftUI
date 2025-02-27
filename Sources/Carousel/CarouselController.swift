//
//  CarouselController.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
import Foundation
import SwiftUI

public class CarouselController: ObservableObject {
    public static let defaultDeltaProgress: CGFloat = 0.0002
    
    @Published public var progress: CGFloat
    @Published public var timerStarted: Bool = false
    
    public var deltaProgress: CGFloat
    
    private var displayLink: CADisplayLink?
    
    public init(progress: CGFloat = 0.0, deltaProgress: CGFloat = CarouselController.defaultDeltaProgress) {
        self.progress = progress
        self.deltaProgress = deltaProgress
    }
    
    deinit {
        print("CarouselController deinit")
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @MainActor
    public func startAnimation() {
#if os(iOS)
        let displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink.add(to: .current, forMode: .default)
        displayLink.isPaused = false
        self.displayLink = displayLink
#else
        let displayLink = NSApplication.shared.keyWindow?.displayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = false
        self.displayLink = displayLink
#endif
        self.timerStarted = true
    }
    
    @objc
    private func updateProgress() {
        self.progress -= deltaProgress
    }
    
    public func stopAnimation() {
        displayLink?.isPaused = true
        displayLink?.invalidate()
        timerStarted = false
    }
}
