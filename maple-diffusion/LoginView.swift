//
//  LoginView.swift
//  maple-diffusion
//
//  Created by Tilak Shakya on 21/10/23.
//

import SwiftUI

struct LoginView: View {
    @State private var showPhoneAuthentication = false
    @Binding var isLoggedIn: Bool
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) {
                    Spacer(minLength: 28.3465 + 132.51975 - 28.3465 + (0.5 * 28.3465))

                    VStack(spacing: 10) {
                        Spacer()
                            .frame(height: 0.7 * 28.3465)
                        
                        Text("")
                            .font(.system(size: 30, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        
                        Spacer()

                        // Reemplazamos los botones con spacers para mantener el espacio
                        Spacer().frame(height: -10)  // Ajusta el valor "50" según la altura de tu botón
                        Spacer().frame(height: -10)  // Ajusta el valor "50" según la altura de tu botón
                        
                        phoneButton
                        loginButton
                    }
                    .offset(y: -28.3465 - (0.5 * 28.3465) - 25)  // Modificado aquí
                    .padding(.horizontal, 20)
                    .background(RoundedCorners(color: .black, tl: 44, tr: 44, bl: 0, br: 0))
                    .frame(width: geometry.size.width, height: geometry.size.height / 2.6 - 4 * 28.3465 + (0.7 * 28.3465) - 130)
                }
            }
            .sheet(isPresented: $showPhoneAuthentication) {
                PhoneAuthenticationView(isLoggedIn: $isLoggedIn)
            }
        }
    }

    var phoneButton: some View {
        Button(action: { showPhoneAuthentication.toggle() }) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.white)
                    .padding(.leading)
                Text("Sign up")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .light, design: .default))
            }
            .padding([.top, .bottom, .trailing])
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 13).foregroundColor(Color(red: 0.20, green: 0.20, blue: 0.20, opacity: 1.0)))
            .scaleEffect(0.95)
        }
    }

    var loginButton: some View {
        Button(action: {}) {
            HStack {
                Spacer().frame(width: 30)
                Text("Login")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .light, design: .default))
            }
            .padding([.top, .bottom, .trailing])
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.5), lineWidth: 1))
            .background(RoundedRectangle(cornerRadius: 0, style: .continuous).fill(Color.black))
            .scaleEffect(0.95)
        }
    }

    struct RoundedCorners: View {
        var color: Color = .black
        var tl: CGFloat = 0.0
        var tr: CGFloat = 0.0
        var bl: CGFloat = 0.0
        var br: CGFloat = 0.0

        var body: some View {
            GeometryReader { geometry in
                Path { path in
                    let w = geometry.size.width
                    let h = geometry.size.height

                    path.move(to: CGPoint(x: w / 2.0, y: 0))
                    path.addLine(to: CGPoint(x: w - self.tr, y: 0))
                    path.addArc(center: CGPoint(x: w - self.tr, y: self.tr), radius: self.tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                    path.addLine(to: CGPoint(x: w, y: h - self.br))
                    path.addArc(center: CGPoint(x: w - self.br, y: h - self.br), radius: self.br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                    path.addLine(to: CGPoint(x: self.bl, y: h))
                    path.addArc(center: CGPoint(x: self.bl, y: h - self.bl), radius: self.bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                    path.addLine(to: CGPoint(x: 0, y: self.tl))
                    path.addArc(center: CGPoint(x: self.tl, y: self.tl), radius: self.tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                }
                .fill(self.color)
            }
        }
    }
}


import SwiftUI

import FirebaseAuth


struct PhoneAuthenticationView: View {
    @StateObject var loginModel = LoginViewModel()
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @Binding var isLoggedIn: Bool
    

    let customBlueColor = Color(UIColor(red: 0.20, green: 0.28, blue: 0.96, alpha: 1.0))

    var isDataEntered: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !loginModel.mobileNo.isEmpty
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Sign out")
                        .foregroundColor(customBlueColor)
                        .font(.body)
                        .onTapGesture {
                            signOut()
                        }

                    Spacer().frame(height: 15)

                    Text("Finish creating your\nImage Creator AI account")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Spacer().frame(height: 4)

                    Text("Tell us about you.")
                        .font(.system(size: 15)) // Hacer el texto un poco más pequeño
                        .foregroundColor(Color(UIColor(white: 0.2, alpha: 1))) // Cambiar el color a un negro con un 20% de gris
                }
                
                Spacer()
            }
            .padding(.top, 40)
            
            VStack(spacing: 20) {
                TextField("First name", text: $firstName)
                    .configureField()

                TextField("Last name", text: $lastName)
                    .configureField()

                TextField("Enter phone number with + and no spaces", text: $loginModel.mobileNo)
                    .keyboardType(.namePhonePad)
                    .configureField()

                if loginModel.showOTPField {
                    TextField("Enter code", text: $loginModel.otpCode)
                        .keyboardType(.numberPad)
                        .configureField()
                }
            }
            .padding(.top, 30)  // Ajuste para mover las cajas un poco hacia abajo

            Spacer()

            Button(action: {
                if loginModel.showOTPField {
                   loginModel.verifyOTPCode()
                } else {
                    loginModel.getOTPCode()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDataEntered ? customBlueColor : customBlueColor.opacity(0.5))
                        .frame(height: 55)

                    Text(loginModel.showOTPField ? "Verify code" : "Continue")
                        .foregroundColor(Color.white)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .disabled(!isDataEntered)
            .padding(.bottom, 15)
            .onReceive(loginModel.$isUserSignedIn) { newValue in
                isLoggedIn = newValue
            }
        }
        .padding([.leading, .trailing], 10)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $loginModel.showError) {
            Alert(title: Text("Error"), message: Text(loginModel.errorMessage), dismissButton: .default(Text("Ok")))
        }
    }
}

extension View {
    func configureField() -> some View {
        self
            .padding(.leading, 8.5)
            .foregroundColor(.black)
            .padding(.vertical, 10)
            .frame(height: 68)
            .background(RoundedRectangle(cornerRadius: 7).stroke(Color.gray.opacity(0.5), lineWidth: 0.7))
    }
}

struct PhoneAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneAuthenticationView(isLoggedIn: .constant(true))
    }
}
