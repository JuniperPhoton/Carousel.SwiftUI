//
//  CarouselController.swift
//  Carousel.SwiftUI
//
//  Created by JuniperPhoton on 2025/2/27.
//
public class CarouselController: ObservableObject {
    @Published public var progress: CGFloat
    
    private var timer: Timer?
    private var deltaProgress: CGFloat
    
    public init(progress: CGFloat = 0.0, deltaProgress: CGFloat = 0.0002) {
        self.progress = progress
        self.deltaProgress = deltaProgress
    }
    
    public func startAnimation() {
        timer?.invalidate()
                
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.leadingProgress -= deltaProgress
            self.centerProgress += deltaProgress
            self.trailingProgress -= deltaProgress
        }
        
        self.timerStarted = true
    }
    
    public func stopAnimation() {
        timer?.invalidate()
        timer = nil
        timerStarted = false
    }
}
