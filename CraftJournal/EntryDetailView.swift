//
//  EntryDetailView.swift
//  CraftJournal
//
//  Created by iMac07 on 9/29/26.
//

import SwiftUI
import CoreData

struct EntryDetailView: View {
    @ObservedObject var entry: CraftEntry
    @State private var showingEditEntry = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()
                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                if let date = entry.date {
                    Text(date, style: .date)
                }
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                }
                if let artisanName = entry.artisanName, !artisanName.isEmpty {
                    Text("Artisan: \(artisanName)")
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if let photoData = entry.photo,
                   let uiImage = UIImage(data: photoData) {

                    ShareLink(
                        item: photoData,
                        preview: SharePreview(
                            entry.title ?? "Craft Photo",
                            image: Image(uiImage: uiImage)
                        )
                    ) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                Button("Edit") {
                    showingEditEntry = true
                }
            }
        }
        .sheet(isPresented: $showingEditEntry) {
            EditEntryView(entry: entry)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
