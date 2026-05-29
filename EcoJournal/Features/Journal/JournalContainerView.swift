//
//  JournalContainerView.swift
//  EcoJournal
//
//  Created by David Contreras on 5/9/26.
//

import SwiftUI

struct JournalContainerView: View {
    let journal: Journal

    var body: some View {
        JournalTabView(journal: journal)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        JournalContainerView(journal: Journal(name: "Olympic National Park"))
    }
}
