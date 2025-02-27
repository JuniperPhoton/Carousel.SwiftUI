//
//  CarouselLayout.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
import SwiftUI

/// A Custom Layout to achieve the vertical Carousel layout that:
/// - Support infinite-scrolling like animation.
/// - Support external control of the animation progress. See ``progress``.
///
/// Typically you use the layouts to build the phot-wall like feature, showing a list of images in a vertical/horizontal layout
/// with infinite-scrolling animation.
///
/// When the progress is 0, the layout will be like `VStack`, but with no alignment and spacing support.
/// To align the content on the cross axis or adding spacings, you should do it on your sub views.
///
/// Example code:
///
/// ```swift
/// let controller = CarouselController()
///
/// VCarouselLayout(progress: controller.progress) {
///     ForEach(0..<assets.count) { index in
///         Image(assets[index].resource)
///             .resizeable()
///             .scaledToFill()
///             .frame(height: 100)
///    }
/// }.onAppear {
///     controller.startAnimation()
/// }
/// ```
///
/// To switching between horizontal and vertical layout, it's recommended to use
/// [AnyLayout](https://developer.apple.com/documentation/swiftui/anylayout) in SwiftUI.
///
/// ```swift
/// private var layout: AnyLayout {
///     if viewModel.horizontalLayout {
///         AnyLayout(HCarouselLayout(progress: controller.progress))
///     } else {
///         AnyLayout(VCarouselLayout(progress: controller.progress))
///     }
/// }
///
/// layout {
///     forEachContentView
/// }
/// ```
///
/// > Note: Don't animate the progress directly. Instead, you should use the "timer" style
/// to animate the progress like `Timer` or `CADisplayLink`.
public struct VCarouselLayout: Layout {
    /// The progress of the current animation carousel layout.
    ///
    /// The value of 0 means the layout will be in its initial state.
    ///
    /// The value of 1 means the layout will be in its final state, where the last item
    /// will be fully visible.
    ///
    /// Values greater than 1 mean that it's in the next circle of infinite-scrolling animation.
    /// For instance, the visual effect of progress of 0.1 is equivalent to progress of 1.1.
    ///
    /// You don't change the progress directly, instead, you pass a new value to the ``CarouselController``
    /// for external event changes.
    ///
    /// You can use the ``CarouselController`` to control the animation progress, or you can just use Timer or CADisplayLink
    /// to tick the progress value.
    public private(set) var progress: CGFloat = 0
    
    var idealSize: Binding<CGSize>

    /// Construct the ``VCarouselLayout`` with initial progress.
    ///
    /// See ``VCarouselLayout/progress`` for more information.
    public init(progress: CGFloat, idealSize: Binding<CGSize> = .constant(.zero)) {
        self.progress = progress
        self.idealSize = idealSize
    }
    
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        if subviews.isEmpty {
            return .zero
        }
        
        let firstViewSize = sizeThatFits(proposal: proposal, subviews: subviews.suffix(1))
        let maxSize = sizeThatFits(proposal: proposal, subviews: subviews)
        
        if maxSize.width > 0 && maxSize.height > 0 {
            idealSize.wrappedValue = maxSize
            print("dwccc idealSize set to \(maxSize), for proposal \(proposal)")
        }
        
        let resolvedProposal = proposal.replacingUnspecifiedDimensions()
        return CGSize(
            width: maxSize.width,
            height: min(maxSize.height, resolvedProposal.height)
        )
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let actualProgress = progress - CGFloat(Int(progress))
        
        let totalHeight = sizeThatFits(proposal: proposal, subviews: subviews).height
        var top = bounds.minY - actualProgress * totalHeight
        let leading = bounds.minX
        
        for view in subviews {
            let size = view.sizeThatFits(proposal)
            let targetBounds = CGRect(
                origin: CGPoint(x: leading, y: top),
                size: size
            )
            
            if targetBounds.maxY < bounds.minY {
                view.place(
                    at: CGPoint(x: leading, y: targetBounds.minY + totalHeight),
                    proposal: .init(bounds.size)
                )
            } else if targetBounds.minY > bounds.maxY {
                view.place(
                    at: CGPoint(x: leading, y: targetBounds.maxY - totalHeight - targetBounds.height),
                    proposal: .init(bounds.size)
                )
            } else {
                view.place(
                    at: CGPoint(x: leading, y: top),
                    proposal: .init(bounds.size)
                )
            }
            
            top += size.height
        }
    }
    
    private func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> CGSize {
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            width = max(width, viewSize.width)
            height += viewSize.height
        }
        
        return CGSize(width: width, height: height)
    }
}
