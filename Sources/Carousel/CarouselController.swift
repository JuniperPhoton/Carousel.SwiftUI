//
//  CarouselController.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
import Foundation
import SwiftUI

/// A helper controller to control the offset of the ``HCarouselLayout`` and ``VCarouselLayout``.
///
/// You use ``startAnimation()`` and ``stopAnimation()`` to control the animation.
public class CarouselController: ObservableObject {
    public static let defaultDeltaOffset: CGFloat = 0.2
    
    /// The observer can observe the offset (in points) of the animation.
    @Published public var offset: CGFloat
    
    /// Check if the animation is started.
    @Published public var timerStarted: Bool = false
    
    /// The delta offset of the animation.
    /// You can use ``CarouselController/defaultDeltaOffset`` as the default value, or change it to your own value
    /// in runtime.
    public var deltaOffset: CGFloat
    
    private var displaySyncer: DisplaySyncer
    
    /// Construct the ``CarouselController`` with initial offset, delta offset and the display syncer.
    /// - parameter displaySyncer: An `DisplaySyncer` instance to sync the animation.
    public init(
        offset: CGFloat = 0.0,
        deltaOffset: CGFloat = CarouselController.defaultDeltaOffset,
        displaySyncer: DisplaySyncer? = nil
    ) {
        self.offset = offset
        self.deltaOffset = deltaOffset
        
        if let displaySyncer {
            self.displaySyncer = displaySyncer
        }  else {
#if os(iOS)
            self.displaySyncer = DefaultCADisplayLinkSyncer()
#else
            self.displaySyncer = KeyWindowCADisplayLinkSyncer()
#endif
        }
        
        self.displaySyncer.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.offset += self.deltaOffset
        }
    }
    
    deinit {
        print("CarouselController deinit")
        displaySyncer.stopAnimation()
    }
    
    @MainActor
    public func startAnimation() {
        displaySyncer.startAnimation()
    }
    
    public func stopAnimation() {
        displaySyncer.stopAnimation()
        timerStarted = false
    }
}
