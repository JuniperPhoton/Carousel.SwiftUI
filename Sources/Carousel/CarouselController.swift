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
    public static let defaultDeltaOffset: CGFloat = 0.2
    
    /// The observer can observe the progress of the animation.
    @Published public var offset: CGFloat
    
    /// Check if the animation is started.
    @Published public var timerStarted: Bool = false
    
    /// The delta progress of the animation.
    /// You can use ``CarouselController/defaultDeltaOffset`` as the default value, or change it to your own value
    /// in runtime.
    public var deltaOffset: CGFloat
    
    private var displayLink: CADisplayLink?
    
    /// Construct the ``CarouselController`` with initial progress and delta progress.
    public init(offset: CGFloat = 0.0, deltaOffset: CGFloat = CarouselController.defaultDeltaOffset) {
        self.offset = offset
        self.deltaOffset = deltaOffset
    }
    
    deinit {
        print("CarouselController deinit")
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @MainActor
    public func startAnimation() {
#if os(iOS)
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
        displayLink.isPaused = false
        self.displayLink = displayLink
#else
        let displayLink = NSApplication.shared.keyWindow?.displayLink(target: self, selector: #selector(update))
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
    private func update() {
        self.offset -= deltaOffset
    }
}
