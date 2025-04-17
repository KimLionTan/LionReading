//
//  EditLabelView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct EditLabelView: View {
    let label: Label
    @Binding var labelName: String
    var onSave: (String) -> Void
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Background()
                
                VStack {
                    TextField("Label Name", text: $labelName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding()
                    
                    Button("Save Changes") {
                        let trimmedName = labelName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty {
                            onSave(trimmedName)
                            isPresented = false
                        }
                    }
                    .disabled(labelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding()
                    .background(labelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding()
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Label")
            .navigationBarItems(
                trailing: Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)
                .fontWeight(.bold)
            )
        }
    }
}
