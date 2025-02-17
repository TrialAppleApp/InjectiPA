//
//  file.swift
//  InjectiPA
//
//  Created by TrialMacApp on 2025-02-17.
//

import SwiftUI

struct FileSelectionRow: View {
    let icon: String
    let title: String
    let extensions: [String]
    @Binding var selection: URL?
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)

                Text(selection?.lastPathComponent ?? String(localized: "No file selected"))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                Button("Browse") {
                    selectFile()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(6)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.textBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue.opacity(isHovering ? 0.5 : 0.2), lineWidth: 1)
            )
            .onHover { hovering in
                isHovering = hovering
            }
            .onDrop(of: [.fileURL], isTargeted: .none) { providers in
                guard let provider = providers.first else { return false }

                provider.loadObject(ofClass: URL.self) { url, _ in
                    if let url = url, extensions.contains(url.pathExtension) {
                        DispatchQueue.main.async {
                            selection = url
                        }
                    } else {
                        NSSound.beep()
                    }
                }
                return true
            }
        }
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.title = "Select File"
        panel.allowedFileTypes = extensions
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false

        if panel.runModal() == .OK {
            selection = panel.url
        }
    }
}
