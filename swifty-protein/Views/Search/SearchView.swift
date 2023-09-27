//
//  SearchView.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Ligments")
                Image(systemName: "magnifyingglass.circle.fill")
                    .symbolRenderingMode(.monochrome)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .clipped()
            Divider()
            VStack {
                ScrollView {
                    VStack {
                        ForEach(0..<5) { _ in // Replace with your data model here
                            HStack {
                                Text("Hello, World!")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .clipped()
                                Image(systemName: "chevron.right")
                                    .symbolRenderingMode(.monochrome)
                            }
                            .frame(height: 20)
                            .clipped()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
