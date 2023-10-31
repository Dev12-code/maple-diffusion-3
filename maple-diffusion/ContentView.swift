
import SwiftUI
import SDWebImageSwiftUI
import OpenAIKit
import Photos
import StoreKit

@main
struct MainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ImageSearchView()
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}

struct MainContentView: View {
    var body: some View {
        NavigationView {
            ImageSearchView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}




import StoreKit


final class ImageSearchViewModel: NSObject, ObservableObject, SKPaymentTransactionObserver {
    private var openai: OpenAI?

    override init() {
        super.init()  // Llama al inicializador de NSObject
        SKPaymentQueue.default().add(self) // Agrega el delegado para manejar las transacciones de compra

    }

    func configure() {
        openai = OpenAI(Configuration(organizationId: "Personal", apiKey: "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"))

    }

    func generateImages(prompt: String, onUpdate: @escaping (Double) -> Void) async -> [UIImage] {
        guard let openai = openai else {
            return []
        }
        var images: [UIImage] = []

        let maxAttempts = 10
        for i in 0..<maxAttempts {
            if images.count == 6 { break }
            do {
                let params = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)
                let result = try await openai.createImage(parameters: params)
                let data = result.data[0].image
                let image = try openai.decodeBase64Image(data)
                images.append(image)
                onUpdate(Double(images.count) / Double(6))
            } catch {
                print(String(describing: error))
            }
        }
        return images

    }


    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // La compra fue exitosa, realiza las acciones necesarias aquí
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                // La compra falló, maneja el error aquí
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                // La compra fue restaurada, maneja las acciones necesarias aquí
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}


enum ActiveSheet: Identifiable {
    case image, subscription
    var id: Int {
        switch self {
        case .image:
            return 0

        case .subscription:
            return 1

        }
    }
}


import SwiftUI
import Foundation

// Modelo para la respuesta
struct ImageAPIResponse: Codable {
    let status: String
    let generationTime: Double
    let id: Int
    let output: [String]
}

// Clase ImageRequester para manejar la solicitud
class ImageRequester: ObservableObject {
    @Published var imageUrls: [String] = []
    
    func sendRequest(with text: String) {
        guard let url = URL(string: "") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "key": "sHp3cl97dDtCvd8NcfYPXas5OVMYbb9LwC9zXfrpxPrUKhhbiExTSUKkcwga", // Coloca aquí tu API Key
            "prompt": text,
            "Safety_Checker": "yes",
            "width": "512",
            "height": "512",
            "samples": "1",
            "num_inference_steps": "20",
            //... otros parámetros necesarios
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(ImageAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.imageUrls = result.output
                }
            } catch {
                print("Error decoding JSON:", error)
            }
        }
        task.resume()
    }
}

// Interfaz principal
struct ContentView: View {
    @State private var inputText: String = ""
    @ObservedObject var imageRequester = ImageRequester()
    
    var body: some View {
        VStack {
            TextField("Ingrese el texto", text: $inputText)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
            
            Button("Enviar") {
                imageRequester.sendRequest(with: inputText)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            List(imageRequester.imageUrls, id: \.self) { imageUrl in
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
            }
        }
    }
}


struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
