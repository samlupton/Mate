//
//  LoginView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/28/23.
//

import SwiftUI
import Firebase
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init() {
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}

struct WelcomeScreen: View {
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    
//    @State private var isLoggedIn: Bool = false
    
    var body: some View {
        NavigationView {
            Group {
                if isLoggedIn {
                    ContentView()
                }
                else {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [.white, Color("PrimaryGold")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                        VStack(spacing: 16) {
                            Spacer()
                            HStack {
                                VStack {
                                    HStack {
                                        Text("Welcome to")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    HStack {
                                        Text("Mate.")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                }
                            }
                            Spacer()
                            NavigationLink(destination: SignInView(email: $email, password: $password, username: $username, confirmPassword: $confirmPassword, isLoggedIn: $isLoggedIn)) {
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(30)
                            }
                            
                            NavigationLink(destination: SignUpView(email: $email, password: $password, username: $username, comfirmPassword: $confirmPassword, isLoggedIn: $isLoggedIn)) {
                                Text("Sign Up")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(30)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                }
            }
        }.onAppear() {
            UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
        .accentColor(.white)
    }
}

struct SignInView: View {
    
    @Binding var email: String
    @Binding var password: String
    @Binding var username: String
    @Binding var confirmPassword: String
    @Binding var isLoggedIn: Bool
    @State private var showSignUpView = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.gray, .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray, lineWidth: 0)
                    .opacity(0.5).background(Color.white)
                VStack {
                    HStack {
                        Text("Sign In")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                            .foregroundColor(Color.black)
                    }
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(Color.black)
                        TextField("email", text: $email).accentColor(Color.black)
                    }.padding()
                    
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(Color.black)
                        SecureField("Password", text: $password).accentColor(Color.black)
                    }.padding()
                    
                    if isLoggedIn {
                        NavigationLink(destination: ContentView(), isActive: $isLoggedIn) {
                        }
                    } else {
                        Button(action: {
                            loginUser()
                        }) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(30)
                        }.padding()
                    }
                    
                }.padding()
                Spacer()
            }
            .cornerRadius(30)
            .frame(height: 150)
            .edgesIgnoringSafeArea(.all)
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                showAlert = true
                alertMessage = error.localizedDescription
            } else {
                isLoggedIn = true
                persistLogin()
            }
        }
    }
    func persistLogin() {
        UserDefaults.standard.set(self.isLoggedIn, forKey: "isLoggedIn")
    }
}

struct SignUpView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var username: String
    @Binding var comfirmPassword: String
    @Binding var isLoggedIn: Bool
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.gray, .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.gray, lineWidth: 0)
                    .opacity(0.5).background(Color.white)
                VStack {
                    HStack {
                        Text("Sign Up")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                            .foregroundColor(Color.black)
                    }
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(Color.black)
                        TextField("Email", text: $email).accentColor(Color.black)
                    }.padding()
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(Color.black)
                        SecureField("Password", text: $password).accentColor(Color.black)
                    }.padding()
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(Color.black)
                        SecureField("Confirm Password", text: $comfirmPassword).accentColor(Color.black)
                    }
                    .padding()
                    if isLoggedIn {
                        NavigationLink(destination: ContentView(), isActive: $isLoggedIn) {
                        }
                    } else {
                        Button(action: {
                            createAccount()
                        }) {
                            Text("Sign Up")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.gray)
                                .cornerRadius(30)
                        }.padding()
                    }
                }.padding()
                Spacer()
            }
            .cornerRadius(30)
            .frame(height: 150)
            .edgesIgnoringSafeArea(.all)
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
    
    func createAccount() {
        guard !email.isEmpty, !password.isEmpty else {
            showAlert = true
            alertMessage = "Please fill in all fields."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                showAlert = true
                alertMessage = error.localizedDescription
            } else {
                isLoggedIn = true
                email = ""
                password = ""
                print("User created successfully.")
            }
        }
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                showAlert = true
                alertMessage = error.localizedDescription
            } else {
                print("User was logged in.")
                persistLogin()
                isLoggedIn = true
            }
        }
    }
    
    func persistLogin() {
        UserDefaults.standard.set(self.isLoggedIn, forKey: "isLoggedIn")
    }
}



struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen()
    }
}
