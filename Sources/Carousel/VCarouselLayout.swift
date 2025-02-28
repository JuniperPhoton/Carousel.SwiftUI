//
//  CarouselLayout.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
import SwiftUI

/// A Custom Layout to achieve the vertical Carousel layout that:
/// - Support infinite-scrolling like animation.
/// - Support external control of the animation offset. See ``offset``.
///
/// Typically you use the layouts to build the photo-wall like feature, showing a list of images in a vertical/horizontal layout
/// with infinite-scrolling animation.
///
/// When the offset is 0, the layout will be like `VStack`, but with no alignment and spacing support.
/// To align the content on the cross axis or adding spacings, you should do it on your sub views.
///
/// Example code:
///
/// ```swift
/// let controller = CarouselController()
///
/// VCarouselLayout(offset: controller.offset) {
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
///         AnyLayout(HCarouselLayout(offset: controller.offset))
///     } else {
///         AnyLayout(VCarouselLayout(offset: controller.offset))
///     }
/// }
///
/// layout {
///     forEachContentView
/// }
/// ```
///
/// > Note: Don't animate the offset directly. Instead, you should use the "timer" style
/// to animate the offset like `Timer` or `CADisplayLink`.
public struct VCarouselLayout: Layout {
    /// The offset of the current animation carousel layout in points.
    ///
    /// Offset that is greater than 0 means the layout will be scrolled up, wise versa.
    ///
    /// You don't change the offset directly, instead, you pass a new value to the ``CarouselController``
    /// for external event changes.
    ///
    /// You can use the ``CarouselController`` to control the animation offset, or you can just use Timer or CADisplayLink
    /// to tick the offset value.
    public private(set) var offset: CGFloat = 0
    
    /// Construct the ``VCarouselLayout`` with initial offset.
    ///
    /// See ``VCarouselLayout/offset`` for more information.
    public init(offset: CGFloat) {
        self.offset = offset
    }
    
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        if subviews.isEmpty {
            return .zero
        }
        
        let maxSize = sizeThatFits(proposal: proposal, subviews: subviews)
        
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
        let totalHeight = sizeThatFits(proposal: proposal, subviews: subviews).height
        let actualOffset = offset.truncatingRemainder(dividingBy: totalHeight)
        var top = bounds.minY - actualOffset
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
