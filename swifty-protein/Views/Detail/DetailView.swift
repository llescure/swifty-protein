//
//  DetailView.swift
//  swifty-protein
//
//  Created by Léa Lescure on 26/09/2023.
//

import SwiftUI

struct DetailView: View {
    let id: String
    
    var body: some View {
        contentView
    }
}

private extension DetailView {
    var contentView: some View {
        Image(systemName: "microbe")
            .font(.largeTitle)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(id: "16A")
    }
}
