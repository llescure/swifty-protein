//
//  MainCoordinator.swift
//  swifty-protein
//
//  Created by Léa Lescure on 27/09/2023.
//

import SwiftUI

struct MainCoordinator: View {
    @State private var capturedView: UIView?
    @State private var path: [PushableView] = []
    @State private var introDidComplete: Bool = false
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        NavigationStack(path: $path) {
            contentView
                .navigationDestination(for: PushableView.self, destination: pushableView)
        }
        .onChange(of: scenePhase) { _ in
            if scenePhase == .background {
                path.removeAll()
            }
        }
        .task {
            do {
                try await Task.sleep(nanoseconds: 3_000_000_000)
            } catch {
                print("error")
            }
            introDidComplete = true
        }
    }
}

internal extension MainCoordinator {
    enum PushableView: Hashable {
        case search
        case detail(Ligand)
    }
    
    @ViewBuilder
    func pushableView(_ view: PushableView) -> some View {
        
        switch view {
        case .search:
            SearchView { ligand in
                path.append(.detail(ligand))
            }
        case let .detail(ligand):
            ShareableDetailView(searchText: ligand.id, onError: { path.removeLast() }) { view in
                self.capturedView = view
            }
                .navigationTitle(ligand.id)
                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.large)
                                Button(action: {
                if let view = capturedView {
                    if let image = captureScreen(view: view) {
                        shareImage(image)
                    }
                }
            }, label: {
                Image(systemName: "square.and.arrow.up")
                    .padding()
            })
                                }
                                }
                                func captureScreen(view: UIView) -> UIImage? {
                let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
                return renderer.image { _ in
                    view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
                }
            }
                                
                                func shareImage(_ image: UIImage) {
                let av = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(av, animated: true, completion: nil)
                }
            }
                                
                                @ViewBuilder
                                var contentView: some View {
                if introDidComplete {
                    LoginView(viewModel: .init()) {
                        path.append(.search)
                    }
                } else {
                    LaunchScreenView()
                        .transition(.opacity)
                }
            }
                                }
