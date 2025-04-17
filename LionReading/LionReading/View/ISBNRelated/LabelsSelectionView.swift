//
//  LabelsSelectionView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct LabelsSelectionView: View {
    @ObservedObject var viewModel: ISBNViewModel
    let loginController: LoginController
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Add labels")
                .font(.headline)
                .padding(.bottom, 4)
            
            if viewModel.availableLabels.isEmpty {
                Text("Loading...")
                    .foregroundColor(.secondary)
            } else {
                // Labels are arranged vertically. Multiple labels can be selected
                VStack(alignment: .leading, spacing: 10) {
                    if !viewModel.availableLabels.filter({ !$0.personalized }).isEmpty {
                        Text("Default Labels")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        ForEach(viewModel.availableLabels.filter { !$0.personalized }) { label in
                            LabelToggleView(
                                label: label,
                                isSelected: viewModel.selectedLabelIds.contains(label.id)
                            ) {
                                viewModel.toggleLabel(id: label.id)
                            }
                        }
                    }
                    
                    if !viewModel.availableLabels.filter({ $0.personalized }).isEmpty {
                        Text("Personal Labels")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        ForEach(viewModel.availableLabels.filter { $0.personalized }) { label in
                            LabelToggleView(
                                label: label,
                                isSelected: viewModel.selectedLabelIds.contains(label.id)
                            ) {
                                viewModel.toggleLabel(id: label.id)
                            }
                        }
                    }
                }
                
                .padding(.bottom, 4)
            }
            
            Button(action: {
                viewModel.showingCustomLabelInput = true
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add personalized label")
                }
                .padding(.vertical, 6)
            }
            
            if viewModel.showingCustomLabelInput {
                HStack {
                    TextField("Personalized Label", text: $viewModel.customLabel)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        viewModel.createNewLabel(loginController: loginController)
                    }) {
                        Text("Add")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
