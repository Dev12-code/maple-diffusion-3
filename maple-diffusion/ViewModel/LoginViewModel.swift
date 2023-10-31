//
//  LoginViewModel.swift
//  maple-diffusion
//
//  Created by Tilak Shakya on 21/10/23.
//

import Combine
import FirebaseAuth
import UIKit
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isUserSignedIn: Bool = false
    var cancellables = Set<AnyCancellable>()

    func getOTPCode() {
        UIApplication.shared.closeKeyboard()
        Task {
            do {
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true // Recuerda cambiar esto en producción
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run {
                    CLIENT_CODE = code
                    showOTPField = true
                }
            } catch {
                await handleError(error: error)
            }
        }
    }

    func verifyOTPCode()  {
        UIApplication.shared.closeKeyboard()
        Task {
            do {
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE,
                                                                        verificationCode: otpCode)
                try await Auth.auth().signIn(with: credential)
                print("¡Éxito al iniciar sesión!")
                
                DispatchQueue.main.async {
                    self.isUserSignedIn = true
                }
            } catch {
                await handleError(error: error)
              
            }
        }
    }

    func handleError(error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
        }
    }
    
    func cancelTasks() {
           cancellables.forEach { $0.cancel() }
           cancellables.removeAll()
       }
}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
