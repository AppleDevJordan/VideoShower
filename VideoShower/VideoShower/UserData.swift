//
//  UserData.swift
//  VideoShower
//
//  Created by Jordan McKnight on 5/2/25.
//
import Foundation



struct UserData {
    var username: String
    var email: String
    var phoneNumber: String
    var password: String
}

func saveUserData(userData: UserData) {
    UserDefaults.standard.set(userData.username, forKey: "username")
    UserDefaults.standard.set(userData.email, forKey: "email")
    UserDefaults.standard.set(userData.phoneNumber, forKey: "phoneNumber")
    UserDefaults.standard.set(userData.password, forKey: "password")
}

struct UserProfileData: Identifiable {
    let id = UUID()
    let username: String
}
