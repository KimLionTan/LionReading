//
//  LabelManagerView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct LabelManagerView: View {
    @ObservedObject var controller: UserController
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showAddLabelSheet = false
    @State private var labelToEdit: Label? = nil
    @State private var editedLabelName = ""
    @State private var showLabelDeletionAlert = false
    @State private var labelToDelete: Label? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Background()
                
                VStack {
                    Text("My Custom Labels")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    if controller.userLabels.isEmpty {
                        Text("You haven't created any custom labels yet.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        List {
                            ForEach(controller.userLabels) { label in
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(.orange)
                                    
                                    Text(label.labelName)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        // First set the edit name, then set the label to edit
                                        editedLabelName = label.labelName
                                        DispatchQueue.main.async {
                                            labelToEdit = label
                                        }
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(BorderlessButtonStyle()) // Prevent click events from spreading
                                    
                                    Button(action: {
                                        labelToDelete = label
                                        showLabelDeletionAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                                .contentShape(Rectangle())
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                        .onAppear {
                            UITableView.appearance().backgroundColor = .clear
                        }
                        .onDisappear {
                            UITableView.appearance().backgroundColor = nil
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            showAddLabelSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add New Label")
                            }
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.orange)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationBarTitle("Label Manager", displayMode: .inline)
            .alert("Confirm Label Deletion", isPresented: $showLabelDeletionAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let label = labelToDelete {
                        let success = controller.deleteLabel(id: label.id)
                        if !success {
                            controller.alertMessage = "Failed to delete label"
                            controller.showAlert = true
                        }
                    }
                }
            } message: {
                if let label = labelToDelete {
                    Text("Are you sure you want to delete the label '\(label.labelName)'? This will remove the label from all books that use it.")
                } else {
                    Text("Are you sure you want to delete this label? This will remove the label from all books that use it.")
                }
            }
            
            .sheet(isPresented: $showAddLabelSheet) {
                AddLabelView(isPresented: $showAddLabelSheet, onAdd: { labelName in
                    let success = controller.addLabel(name: labelName)
                    if !success {
                        controller.alertMessage = "Failed to add label"
                        controller.showAlert = true
                    }
                })
            }
            
            .sheet(item: $labelToEdit) { label in
                EditLabelView(
                    label: label,
                    labelName: Binding(
                        get: { self.editedLabelName },
                        set: { self.editedLabelName = $0 }
                    ),
                    onSave: { updatedName in
                        let success = controller.updateLabel(id: label.id, newName: updatedName)
                        if !success {
                            controller.alertMessage = "Failed to update label"
                            controller.showAlert = true
                        }
                    },
                    isPresented: Binding<Bool>(
                        get: { labelToEdit != nil },
                        set: { if !$0 { labelToEdit = nil } }
                    )
                )
            }
            .alert(isPresented: $controller.showAlert) {
                Alert(
                    title: Text("Message"),
                    message: Text(controller.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onAppear {
            controller.loadUserLabels()
        }
    }
}
