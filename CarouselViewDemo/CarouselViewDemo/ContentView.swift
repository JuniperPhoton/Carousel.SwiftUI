//
//  ContentView.swift
//  CarouselViewDemo
//
//  Created by JuniperPhoton on 2025/2/27.
//
import SwiftUI
import Carousel
import Combine

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
    let leadingController = CarouselController(offset: 400)
    let centerController = CarouselController(offset: -400)
    let trailingController = CarouselController(offset: 0)
    
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
    
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    func fireTimer() {
        timerStarted = true
        leadingController.startAnimation()
        centerController.startAnimation()
        trailingController.startAnimation()
        
        trailingController.$offset
            .combineLatest(leadingController.$offset, centerController.$offset)
            .sink { [weak self] _ in
                guard let self else { return }
                objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func stopTimer() {
        timerStarted = false
        cancellables.removeAll()
        leadingController.stopAnimation()
        centerController.stopAnimation()
        trailingController.stopAnimation()
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
                    offset: Binding(get: {
                        viewModel.leadingController.offset
                    }, set: { value in
                        viewModel.leadingController.offset = value
                    }),
                    enableDragging: true
                ) { state in
                    viewModel.isLeadingTouching = state.isActive
                } content: {
                    forEachContentView
                }
                
                CarouselView(
                    orientation: viewModel.horizontalLayout ? .horizontal : .vertical,
                    offset: Binding(get: {
                        viewModel.centerController.offset
                    }, set: { value in
                        viewModel.centerController.offset = value
                    }),
                    enableDragging: true
                ) { state in
                    viewModel.isCenterTouching = state.isActive
                } content: {
                    forEachContentView
                }
                
                CarouselView(
                    orientation: viewModel.horizontalLayout ? .horizontal : .vertical,
                    offset: Binding(get: {
                        viewModel.trailingController.offset
                    }, set: { value in
                        viewModel.trailingController.offset = value
                    }),
                    enableDragging: true
                ) { state in
                    viewModel.isTrailingTouching = state.isActive
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
        .onAppear {
            viewModel.fireTimer()
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
