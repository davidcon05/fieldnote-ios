//
//  ContentView.swift
//  fieldnote
//
//  Created by David Contreras on 5/5/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
      @Environment(\.modelContext) private var modelContext
      @Query private var journals: [Journal]

      var body: some View {
          NavigationStack {
              List {
                  ForEach(journals) { journal in
                      VStack(alignment: .leading) {
                          Text(journal.name)
                              .font(.headline)
                          Text("\(journal.logs.count) logs")
                              .font(.caption)
                              .foregroundColor(.secondary)
                      }
                  }
                  .onDelete(perform: deleteJournals)
              }
              .navigationTitle("Journals")
              .toolbar {
                  ToolbarItem(placement: .navigationBarTrailing) {
                      EditButton()
                  }
                  ToolbarItem {
                      Button(action: addJournal) {
                          Label("Add Journal", systemImage: "plus")
                      }
                  }
              }
          }
      }

      private func addJournal() {
          withAnimation {
              let newJournal = Journal(name: "Test Journal \(journals.count + 1)")
              modelContext.insert(newJournal)
          }
      }

      private func deleteJournals(offsets: IndexSet) {
          withAnimation {
              for index in offsets {
                  modelContext.delete(journals[index])
              }
          }
      }
  }

  #Preview {
      ContentView()
          .modelContainer(for: Journal.self, inMemory: true)
  }
