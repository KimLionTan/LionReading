//
//  AddLabelView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

// 添加新标签的视图
struct AddLabelView: View {
    @Binding var isPresented: Bool
    @State private var labelName = ""
    var onAdd: (String) -> Void
    
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
                    
                    Button("Add Label") {
                        let trimmedName = labelName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty {
                            onAdd(trimmedName)
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
            .navigationTitle("Add New Label")
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
