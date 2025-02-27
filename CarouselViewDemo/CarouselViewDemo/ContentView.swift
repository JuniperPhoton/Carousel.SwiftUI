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
        ImageData(id: "1", image: .image1),
        ImageData(id: "2", image: .image2),
        ImageData(id: "3", image: .image3),
        ImageData(id: "4", image: .image4),
    ]
    
    private var timer: Timer?
    
    func fireTimer() {
        timer?.invalidate()
        
        let delta = 0.0002
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 120.0, repeats: true) { _ in
            self.leadingProgress -= delta
            self.centerProgress += delta
            self.trailingProgress -= delta
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
        TabView {
            PhotoWallDemo()
                .tabItem {
                    Text("Photo wall")
                }
            
            SwitchLayoutDemo()
                .tabItem {
                    Text("Switch layout")
                }
        }
    }
}

private struct SwitchLayoutDemo: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            layout {
                forEachContentView
            }.clipped()
                .frame(maxHeight: .infinity)
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
            }.buttonStyle(.bordered)
                .controlSize(.large)
                .padding()
        }
    }
    
    private var layout: AnyLayout {
        if viewModel.horizontalLayout {
            AnyLayout(HCarouselLayout(progress: viewModel.leadingProgress))
        } else {
            AnyLayout(VCarouselLayout(progress: viewModel.leadingProgress))
        }
    }
    
    private var forEachContentView: some View {
        ForEach(viewModel.images) { image in
            Image(image.image)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(4)
        }
    }
}

private struct PhotoWallDemo: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            rootLayout {
                leadingLayout {
                    forEachContentView
                }
                
                centerLayout {
                    forEachContentView
                }
                
                trailingLayout {
                    forEachContentView
                }
            }.clipped()
                .frame(maxHeight: .infinity).overlay {
                    Rectangle().fill(
                        LinearGradient(
                            colors: [.black.opacity(0.0), .black.opacity(1.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    ).frame(height: 100)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                    
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
                    .buttonStyle(.bordered)
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
    
    private var leadingLayout: AnyLayout {
        if viewModel.horizontalLayout {
            return AnyLayout(HCarouselLayout(progress: viewModel.leadingProgress))
        } else {
            return AnyLayout(VCarouselLayout(progress: viewModel.leadingProgress))
        }
    }
    
    private var centerLayout: AnyLayout {
        if viewModel.horizontalLayout {
            return AnyLayout(HCarouselLayout(progress: viewModel.centerProgress))
        } else {
            return AnyLayout(VCarouselLayout(progress: viewModel.centerProgress))
        }
    }
    
    private var trailingLayout: AnyLayout {
        if viewModel.horizontalLayout {
            return AnyLayout(HCarouselLayout(progress: viewModel.trailingProgress))
        } else {
            return AnyLayout(VCarouselLayout(progress: viewModel.trailingProgress))
        }
    }
    
    private var forEachContentView: some View {
        ForEach(viewModel.images) { image in
            Image(image.image)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(4)
        }
    }
}

#Preview {
    CarouselDemoView().frame(width: 400, height: 500)
        .preferredColorScheme(.dark)
}
