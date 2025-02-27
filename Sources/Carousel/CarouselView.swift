//
//  CarouselView.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
import SwiftUI

/// A helper `View` to display content in a Carousel Layout horizontally or vertically.
///
/// Example Code:
///
/// ```swift
/// CarouselView(
///     orientation: viewModel.horizontalLayout ? .horizontal : .vertical,
///     progress: viewModel.leadingProgress
/// ) {
///     ForEach(0..<assets.count) { index in
///         Image(assets[index].resource)
///             .resizeable()
///             .scaledToFill()
///             .frame(height: 100)
///    }
/// }
/// ```
///
/// > Note: You can also use the layout direclty. Please refer to ``VCarouselLayout`` and ``HCarouselLayout`` for more details.
public struct CarouselView<Content: View>: View {
    /// The orientation of the carousel.
    var orientation: Axis
    
    /// See ``VCarouselLayout/progress``.
    var progress: CGFloat
    
    @ViewBuilder
    var content: () -> Content
    
    public init(orientation: Axis, progress: CGFloat, content: @escaping () -> Content) {
        self.orientation = orientation
        self.progress = progress
        self.content = content
    }

    public var body: some View {
        layout {
            content()
        }
    }
    
    private var layout: AnyLayout {
        switch orientation {
        case .horizontal:
            AnyLayout(HCarouselLayout(progress: progress))
        case .vertical:
            AnyLayout(VCarouselLayout(progress: progress))
        }
    }
}
