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
///     offset: viewModel.leadingOffset
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
    
    /// See ``VCarouselLayout/offset``.
    var offset: Binding<CGFloat>
    
    var enableDragging: Bool = false
    var onDragStateChanged: ((DragState) -> Void)?
    
    @ViewBuilder
    var content: () -> Content
    
    @StateObject private var gestureState = GestureState()
    
    private var gesture: some Gesture {
        DragGesture().onChanged { value in
            if gestureState.dragStartedOffset == nil {
                gestureState.dragStartedOffset = offset.wrappedValue
            }
            gestureState.dragTranslation = value.translation
            onDragStateChanged?(DragState(isDragging: true, isEnding: false))
        }.onEnded { value in
            if let dragStartedOffset = gestureState.dragStartedOffset {
                let predictedEndTranslation = value.predictedEndTranslation
                
                let time: TimeInterval
                let destinationOffset: CGFloat
                
                switch orientation {
                case .horizontal:
                    time = (predictedEndTranslation.width - value.translation.width) / value.velocity.width
                    destinationOffset = dragStartedOffset - predictedEndTranslation.width
                case .vertical:
                    time = (predictedEndTranslation.height - value.translation.height) / value.velocity.height
                    destinationOffset = dragStartedOffset - predictedEndTranslation.height
                }
                
                onDragStateChanged?(DragState(isDragging: false, isEnding: true))
                gestureState.animating = true
                gestureState.animate(
                    start: offset.wrappedValue,
                    dest: destinationOffset,
                    time: time * 3
                ) { value in
                    offset.wrappedValue = value
                } onCancelOrComplete: {
                    gestureState.animating = false
                    onDragStateChanged?(.inactive)
                }
            }
            
            gestureState.dragStartedOffset = nil
        }
    }
    
    /// Construct the `CarouselView` with orientation, offset, enableDragging and content.
    ///
    /// - parameter orientation: The orientation of the carousel.
    /// This property suppots animation, you can trigger the animation by changing the orientation with `withAnimation`.
    /// - parameter offset: The offset of the carousel in Pixel. It uses Binding so that this view can change it with drag gesture.
    /// - parameter enableDragging: Enable the drag gesture to change the offset.
    /// There are some tiny details to refine the dragging gesture. Test this to see if it fits your needs.
    /// - parameter onDragStateChanged: A closure that will be called when the dragging state is changed.
    /// - parameter content: The content of the carousel. You can use `ForEach` to create multiple content views.
    /// Note that SwiftUI doesn't provide a method to implement custom lazy layout, so keep the number of views in a reasonable range,
    /// as this view aims to provide infinite scrolling animation with a small amount of views.
    public init(
        orientation: Axis,
        offset: Binding<CGFloat>,
        enableDragging: Bool = false,
        onDragStateChanged: ((DragState) -> Void)? = nil,
        content: @escaping () -> Content
    ) {
        self.orientation = orientation
        self.offset = offset
        self.onDragStateChanged = onDragStateChanged
        self.enableDragging = enableDragging
        self.content = content
    }
    
    public var body: some View {
        layout {
            content()
        }.gesture(gesture, including: enableDragging && !gestureState.animating ? .all : .none)
            .onChange(of: gestureState.dragTranslation.width) { newValue in
                if orientation == .horizontal, let dragStartedOffset = gestureState.dragStartedOffset {
                    offset.wrappedValue = dragStartedOffset - newValue
                }
            }
            .onChange(of: gestureState.dragTranslation.height) { newValue in
                if orientation == .vertical, let dragStartedOffset = gestureState.dragStartedOffset {
                    offset.wrappedValue = dragStartedOffset - newValue
                }
            }
    }
    
    private var layout: AnyLayout {
        switch orientation {
        case .horizontal:
            AnyLayout(HCarouselLayout(offset: offset.wrappedValue))
        case .vertical:
            AnyLayout(VCarouselLayout(offset: offset.wrappedValue))
        }
    }
}

private class GestureState: ObservableObject {
    @Published var dragTranslation: CGSize = .zero
    @Published var animating = false
    
    var dragStartedOffset: CGFloat? = nil
    
    private var animator: ValueAnimator?
    
    func animate(
        start: CGFloat,
        dest: CGFloat,
        time: TimeInterval,
        onUpdateValue: @escaping (CGFloat) -> Void,
        onCancelOrComplete: (() -> Void)? = nil
    ) {
        animator = ValueAnimator(from: start, to: dest, duration: time) { value in
            onUpdateValue(CGFloat(value))
        }
        animator?.onCancel = {
            onCancelOrComplete?()
        }
        animator?.start()
    }
}

/// todo: provide a better easing function.
fileprivate var defaultEasingFunction: (TimeInterval, TimeInterval) -> (Double) = { time, duration in
    let t = time / duration
    return 1 - pow(1 - t, 4)
}

/// From: https://stackoverflow.com/questions/61594608/ios-equivalent-of-androids-valueanimator
fileprivate class ValueAnimator {
    let from: Double
    let to: Double
    var duration: TimeInterval = 0
    var startTime: Date!
    var displayLink: CADisplayLink?
    var animationCurveFunction: (TimeInterval, TimeInterval) -> (Double)
    var valueUpdater: (Double) -> Void
    
    var onCancel: (() -> Void)? = nil
    
    init (
        from: Double = 0,
        to: Double = 1,
        duration: TimeInterval,
        animationCurveFunction: @escaping (TimeInterval, TimeInterval) -> (Double) = defaultEasingFunction,
        valueUpdater: @escaping (Double) -> Void
    ) {
        self.from = from
        self.to = to
        self.duration = duration
        self.animationCurveFunction = animationCurveFunction
        self.valueUpdater = valueUpdater
    }
    
    func start() {
#if os(macOS)
        let displayLink = NSApplication.shared.keyWindow?.displayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = false
        self.displayLink = displayLink
#else
        let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: .main, forMode: .default)
        displayLink.isPaused = false
        self.displayLink = displayLink
#endif
    }
    
    @objc
    private func update() {
        if startTime == nil {
            startTime = Date()
            valueUpdater(from + (to - from) * animationCurveFunction(0, duration))
            return
        }
        
        var timeElapsed = Date().timeIntervalSince(startTime)
        var stop = false
        
        if timeElapsed > duration {
            timeElapsed = duration
            stop = true
        }
        
        valueUpdater(from + (to - from) * animationCurveFunction(timeElapsed, duration))
        
        if stop {
            cancel()
        }
    }
    
    func cancel() {
        self.displayLink?.isPaused = true
        self.displayLink?.invalidate()
        self.displayLink = nil
        self.onCancel?()
    }
}
