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
    var progress: Binding<CGFloat>
    
    var onTouchStateChanged: (Bool) -> Void
    
    @ViewBuilder
    var content: () -> Content
    
    @StateObject private var gestureState = GestureState()
    
    private var gesture: some Gesture {
        DragGesture().onChanged { value in
            if gestureState.dragStartedProgress == nil {
                gestureState.dragStartedProgress = progress.wrappedValue
            }
            gestureState.dragTranslation = value.translation
            onTouchStateChanged(true)
        }.onEnded { value in
            let predictedEndTranslation = value.predictedEndTranslation
            if orientation == .horizontal, gestureState.idealSize.width > 0, let startProgress = gestureState.dragStartedProgress {
                let time = (predictedEndTranslation.width - value.translation.width) / value.velocity.width
                gestureState.timerToSet(
                    target: startProgress - predictedEndTranslation.width * gestureState.horizontalProgressPerPoint,
                    time: time * 3,
                    progress: progress
                )
                onTouchStateChanged(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + time * 3) {
                    onTouchStateChanged(false)
                }
            } else if orientation == .vertical, gestureState.idealSize.height > 0, let startProgress = gestureState.dragStartedProgress {
                let time = (predictedEndTranslation.height - value.translation.height) / value.velocity.height
                gestureState.timerToSet(
                    target: startProgress - predictedEndTranslation.height * gestureState.verticalProgressPerPoint,
                    time: time * 3,
                    progress: progress
                )
                onTouchStateChanged(true)
                DispatchQueue.main.asyncAfter(deadline: .now() + time * 3) {
                    onTouchStateChanged(false)
                }
            }
            gestureState.dragStartedProgress = nil
        }
    }
    
    public init(
        orientation: Axis,
        progress: Binding<CGFloat>,
        onTouchStateChanged: @escaping (Bool) -> Void,
        content: @escaping () -> Content
    ) {
        self.orientation = orientation
        self.progress = progress
        self.onTouchStateChanged = onTouchStateChanged
        self.content = content
    }
    
    public var body: some View {
        layout {
            content()
        }.gesture(gesture)
            .onChange(of: gestureState.dragTranslation.width) { newValue in
                if orientation == .horizontal, gestureState.idealSize.width > 0, let startProgress = gestureState.dragStartedProgress {
                    progress.wrappedValue = startProgress - newValue * gestureState.horizontalProgressPerPoint
                }
            }
            .onChange(of: gestureState.dragTranslation.height) { newValue in
                if orientation == .vertical, gestureState.idealSize.height > 0, let startProgress = gestureState.dragStartedProgress {
                    progress.wrappedValue = startProgress - newValue * gestureState.verticalProgressPerPoint
                }
            }
    }
    
    private var layout: AnyLayout {
        switch orientation {
        case .horizontal:
            AnyLayout(HCarouselLayout(progress: progress.wrappedValue, idealSize: Binding(get: {
                .zero
            }, set: { value in
                gestureState.idealSize = value
            })))
        case .vertical:
            AnyLayout(VCarouselLayout(progress: progress.wrappedValue, idealSize: Binding(get: {
                .zero
            }, set: { value in
                gestureState.idealSize = value
            })))
        }
    }
}

private class GestureState: ObservableObject {
    var startLocation: CGPoint? = nil
    var dragStartedProgress: CGFloat? = nil
    var idealSize: CGSize = .zero
    @Published var dragTranslation: CGSize = .zero
    
    var horizontalProgressPerPoint: CGFloat {
        if idealSize.width > 0 {
            1.0 / idealSize.width
        } else {
            0.0
        }
    }
    
    var verticalProgressPerPoint: CGFloat {
        if idealSize.height > 0 {
            1.0 / idealSize.height
        } else {
            0.0
        }
    }
    
    private var animator: ValueAnimator?
    
    func timerToSet(target: CGFloat, time: TimeInterval, progress: Binding<CGFloat>) {
        animator?.cancel()
        animator = ValueAnimator(from: progress.wrappedValue, to: target, duration: time) { value in
            progress.wrappedValue = CGFloat(value)
        }
        animator?.start()
    }
}

fileprivate var defaultEasingFunction: (TimeInterval, TimeInterval) -> (Double) = { time, duration in
    let t = time / duration
    return 1 - pow(1 - t, 4)
}

class ValueAnimator {
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
        
        print("dwccc duration is \(duration)")
    }
    
    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .current, forMode: .default)
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
        self.displayLink?.remove(from: .current, forMode: .default)
        self.displayLink = nil
        self.onCancel?()
    }
}
