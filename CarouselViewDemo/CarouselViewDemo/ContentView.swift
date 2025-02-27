//
//  ContentView.swift
//  CarouselViewDemo
//
//  Created by JuniperPhoton on 2025/2/27.
//
import SwiftUI
import Carousel

struct ContentView: View {
    var body: some View {
        CarouselDemoView()
    }
}

struct ImageData: Identifiable {
    let id: String
    let image: ImageResource
}

class ViewModel: ObservableObject {
    @Published var leadingProgress: CGFloat = -0.3
    @Published var centerProgress: CGFloat = 0.0
    @Published var trailingProgress: CGFloat = 0.3
    
    @Published var timerStarted = false
    @Published var horizontalLayout = true
    @Published var images: [ImageData] = [
        ImageData(id: "0", image: .image0),
        ImageData(id: "1", image: .carouselImage1),
        ImageData(id: "2", image: .image2),
        ImageData(id: "3", image: .carouselImage2),
        ImageData(id: "4", image: .image4),
        ImageData(id: "5", image: .carouselImage3),
        ImageData(id: "6", image: .image1),
        ImageData(id: "7", image: .carouselImage4),
        ImageData(id: "8", image: .image3),
        ImageData(id: "9", image: .carouselImage5),
        ImageData(id: "10", image: .carouselImage6),
        ImageData(id: "11", image: .carouselImage7),
        ImageData(id: "12", image: .carouselImage8),
        ImageData(id: "13", image: .carouselImage9),
        ImageData(id: "14", image: .carouselImage10),
    ]
    
    var isLeadingTouching = false
    var isCenterTouching = false
    var isTrailingTouching = false
    
    private var timer: Timer?
    
    func fireTimer() {
        timer?.invalidate()
        
        let delta = 0.0002
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            if !isLeadingTouching {
                self.leadingProgress -= delta
            }
            
            if !isCenterTouching {
                self.centerProgress += delta
            }
            
            if !isTrailingTouching {
                self.trailingProgress -= delta
            }
        }
        
        self.timerStarted = true
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        timerStarted = false
    }
}

public struct CarouselDemoView: View {
    public var body: some View {
        PhotoWallDemo()
    }
}

private struct PhotoWallDemo: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            rootLayout {
                CarouselView(
                    orientation: viewModel.horizontalLayout ? .horizontal : .vertical,
                    progress: $viewModel.leadingProgress
                ) { isTouching in
                    viewModel.isLeadingTouching = isTouching
                } content: {
                    forEachContentView
                }
                
                CarouselView(
                    orientation: viewModel.horizontalLayout ? .horizontal : .vertical,
                    progress: $viewModel.centerProgress
                ) { isTouching in
                    viewModel.isCenterTouching = isTouching
                } content: {
                    forEachContentView
                }
                
                CarouselView(
                    orientation: viewModel.horizontalLayout ? .horizontal : .vertical,
                    progress: $viewModel.trailingProgress
                ) { isTouching in
                    viewModel.isTrailingTouching = isTouching
                } content: {
                    forEachContentView
                }
            }.ignoresSafeArea()
                .frame(maxHeight: .infinity).overlay {
                    Rectangle().fill(
                        LinearGradient(
                            colors: [.black.opacity(0.0), .black.opacity(1.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    ).frame(height: 100)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .ignoresSafeArea()
                    
                    HStack {
                        Button(viewModel.timerStarted ? "Stop Carousel" : "Start Carousel") {
                            if !viewModel.timerStarted {
                                viewModel.fireTimer()
                            } else {
                                viewModel.stopTimer()
                            }
                        }
                        .fixedSize()
                        
                        Button(viewModel.horizontalLayout ? "Horizontal" : "Vertical") {
                            withAnimation {
                                viewModel.horizontalLayout.toggle()
                            }
                        }
                        .fixedSize()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
        }
    }
    
    private var rootLayout: AnyLayout {
        if viewModel.horizontalLayout {
            AnyLayout(VStackLayout(spacing: 0))
        } else {
            AnyLayout(HStackLayout(spacing: 0))
        }
    }
    
    private var forEachContentView: some View {
        ForEach(viewModel.images) { image in
            Image(image.image)
                .resizable()
                .scaledToFit()
                .contentShape(Rectangle())
                .clipped()
                .padding(2)
        }
    }
}

#Preview {
    CarouselDemoView().frame(width: 400, height: 500)
        .preferredColorScheme(.dark)
}
