//
//  CarouselController.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
import Foundation
import SwiftUI

/// A helper controller to control the progress of the ``HCarouselLayout`` and ``VCarouselLayout``.
///
/// You use ``startAnimation()`` and ``stopAnimation()`` to control the animation.
public class CarouselController: ObservableObject {
    public static let defaultDeltaProgress: CGFloat = 0.0002
    
    /// The observer can observe the progress of the animation.
    @Published public var progress: CGFloat
    
    /// Check if the animation is started.
    @Published public var timerStarted: Bool = false
    
    /// The delta progress of the animation.
    /// You can use ``CarouselController/defaultDeltaProgress`` as the default value, or change it to your own value
    /// in runtime.
    public var deltaProgress: CGFloat
    
    private var displayLink: CADisplayLink?
    
    /// Construct the ``CarouselController`` with initial progress and delta progress.
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
    
    public func stopAnimation() {
        displayLink?.isPaused = true
        displayLink?.invalidate()
        timerStarted = false
    }
    
    @objc
    private func updateProgress() {
        self.progress -= deltaProgress
    }
}
