//
//  EditEntryView.swift
//  CraftJournal
//
//  Created by iMac07 on 9/29/26.
//

import SwiftUI
import CoreData
import PhotosUI

struct EditEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entry: CraftEntry

    @State private var title: String
    @State private var notes: String
    @State private var craftType: String
    @State private var artisanName: String
    @State private var image: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?

    init(entry: CraftEntry) {
        self.entry = entry

        _title = State(initialValue: entry.title ?? "")
        _notes = State(initialValue: entry.notes ?? "")
        _craftType = State(initialValue: entry.craftType ?? crafts[0])
        _artisanName = State(initialValue: entry.artisanName ?? "")

        if let data = entry.photo {
            _image = State(initialValue: UIImage(data: data))
        } else {
            _image = State(initialValue: nil)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)

                TextField("Notes", text: $notes, axis: .vertical)

                TextField("Artisan Name", text: $artisanName)

                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }

                Section("Photo") {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                    }

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label(
                            "Choose from Library",
                            systemImage: "photo"
                        )
                    }
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(
                        type: Data.self
                    ) {
                        if let uiImage = UIImage(data: data) {
                            image = uiImage
                        }
                    }
                }
            }
        }
    }

    private func saveChanges() {
        entry.title = title
        entry.notes = notes
        entry.craftType = craftType
        entry.artisanName = artisanName

        if let image {
            entry.photo = image.jpegData(compressionQuality: 0.7)
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not update entry: \(error)")
        }
    }
}
