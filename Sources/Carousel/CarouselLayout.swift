//
//  CarouselLayout.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
import SwiftUI

public struct VCarouselLayout: Layout {
    var progress: CGFloat = 0
    
    public init(progress: CGFloat) {
        self.progress = progress
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
        
        let resolvedProposal = proposal.replacingUnspecifiedDimensions()
        return CGSize(
            width: maxSize.width,
            height: min(maxSize.height, resolvedProposal.height),
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

public struct HCarouselLayout: Layout {
    var progress: CGFloat = 0
    
    public init(progress: CGFloat) {
        self.progress = progress
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
        
        let resolvedProposal = proposal.replacingUnspecifiedDimensions()
        return CGSize(
            width: min(maxSize.width, resolvedProposal.width),
            height: maxSize.height,
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
