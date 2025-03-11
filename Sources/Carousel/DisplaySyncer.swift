//
//  DisplaySyncer.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/28.
//
import Foundation
import SwiftUI

/// Provides a way to synchronize animation to the display.
///
/// It's recommended to use ``NSViewCADisplayLinkSyncer`` or ``KeyWindowCADisplayLinkSyncer`` on macOS
///  and ``DefaultCADisplayLinkSyncer`` on iOS.
public protocol DisplaySyncer: AnyObject {
    /// A block to be called when the display is updated.
    /// For example, when using ``CADisplayLink`` on a iPhone 16 Pro, it should trigger at 120Hz.
    var onUpdate: (() -> Void)? { get set }
    
    /// Start the animation.
    func startAnimation()
    
    /// Stop the animation.
    func stopAnimation()
}

#if os(macOS)
/// A ``DisplaySyncer`` that takes a `NSView` to create a display link.
@available(macOS 14.0, *)
public final class NSViewCADisplayLinkSyncer: DisplaySyncer {
    private var view: NSView?
    private var displayLink: CADisplayLink?
    
    public var onUpdate: (() -> Void)?
    
    public init(view: NSView?) {
        self.view = view
    }
    
    @MainActor
    public func startAnimation() {
        let displayLink = view?.displayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = false
        self.displayLink = displayLink
    }
    
    public func stopAnimation() {
        if let displayLink {
            displayLink.isPaused = true
            displayLink.invalidate()
            self.displayLink = nil
        }
    }
    
    @objc
    private func update() {
        onUpdate?()
    }
}

/// The default `DisplaySyncer` available for macOS, which uses the current key window to create a display link.
///
/// Note: it's better to provide your own view to create the display link using ``NSViewCADisplayLinkSyncer``,
/// since on macOS, the key window may not be the window you want to sync the animation.
@available(macOS 14.0, *)
public final class KeyWindowCADisplayLinkSyncer: DisplaySyncer {
    private var displayLink: CADisplayLink?
    
    public var onUpdate: (() -> Void)? = nil
    
    public init() {
        // empty
    }
    
    @MainActor
    public func startAnimation() {
        if let keyWindow = NSApplication.shared.keyWindow {
            let displayLink = keyWindow.displayLink(target: self, selector: #selector(update))
            displayLink.add(to: .current, forMode: .default)
            displayLink.isPaused = false
            self.displayLink = displayLink
        } else {
            DispatchQueue.main.async {
                self.startAnimation()
            }
        }
    }
    
    public func stopAnimation() {
        if let displayLink {
            displayLink.isPaused = true
            displayLink.invalidate()
            self.displayLink = nil
        }
    }
    
    @objc
    private func update() {
        onUpdate?()
    }
}
#endif

#if os(iOS)
/// The default `DisplaySyncer` available for iOS.
@available(iOS 16.0, *)
public final class DefaultCADisplayLinkSyncer: DisplaySyncer {
    private var displayLink: CADisplayLink?
    
    public var onUpdate: (() -> Void)?
    
    @MainActor
    public func startAnimation() {
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .current, forMode: .default)
        displayLink.isPaused = false
        self.displayLink = displayLink
    }
    
    public func stopAnimation() {
        if let displayLink {
            displayLink.isPaused = true
            displayLink.invalidate()
            self.displayLink = nil
        }
    }
    
    @objc
    private func update() {
        onUpdate?()
    }
}
#endif
