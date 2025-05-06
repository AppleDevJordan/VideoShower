//
//  UserProfileView.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/2/25.
//


import SwiftUI

struct UserProfileView: View {
    var username: String

    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.bottom, 10)

            Text("Profile of \(username)")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Spacer()
        }
        .navigationTitle("User Profile")
        .padding()
    }
}

#Preview {
    UserProfileView(username: "SampleUser")
}
