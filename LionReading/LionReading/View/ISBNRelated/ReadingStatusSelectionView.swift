//
//  ReadingStatusSelectionView.swift
//  LionReading
//
//  Created by TanJianing.
//

import SwiftUI

struct ReadingStatusSelectionView: View {
    @ObservedObject var viewModel: ISBNViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Reading Status")
                .font(.headline)
                .padding(.bottom, 4)
            
            Picker("Reading Status", selection: $viewModel.selectedReadingStatus) {
                ForEach(DatabaseHelper.shared.getReadingStatusOptions(), id: \.self) { status in
                    Text(status).tag(status)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 8)
            
            // Display calendar-related prompts
            if viewModel.selectedReadingStatus == ReadingStatus.alreadyRead.description {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(.orange)
                    Text("Marked-as-read books will have the opportunity to be added to the system calendar.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
