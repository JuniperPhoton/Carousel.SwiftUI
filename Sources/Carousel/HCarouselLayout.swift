//
//  HCarouselLayout.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
import SwiftUI

/// The horizontal version of ``VCarouselLayout``.
///
/// See the comments of ``VCarouselLayout`` for more information.
public struct HCarouselLayout: Layout {
    var progress: CGFloat = 0
    var idealSize: Binding<CGSize>
    
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
            width: min(maxSize.width, resolvedProposal.width),
            height: maxSize.height
        )
    }
    
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let actualProgress = progress - CGFloat(Int(progress))
        
        let totalWidth = sizeThatFits(proposal: proposal, subviews: subviews).width
        let top = bounds.minY
        var leading = bounds.minX - actualProgress * totalWidth
        
        for view in subviews {
            let size = view.sizeThatFits(proposal)
            let targetBounds = CGRect(
                origin: CGPoint(x: leading, y: top),
                size: size
            )
            
            if targetBounds.maxX < bounds.minX {
                view.place(
                    at: CGPoint(x: targetBounds.minX + totalWidth, y: top),
                    proposal: .init(bounds.size)
                )
            } else if targetBounds.minX > bounds.maxX {
                view.place(
                    at: CGPoint(x: targetBounds.maxX - totalWidth - targetBounds.width, y: top),
                    proposal: .init(bounds.size)
                )
            } else {
                view.place(
                    at: CGPoint(x: leading, y: top),
                    proposal: .init(bounds.size)
                )
            }
            
            leading += size.width
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
            width += viewSize.width
            height = max(height, viewSize.height)
        }
        
        return CGSize(width: width, height: height)
    }
}
