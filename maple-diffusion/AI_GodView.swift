//
//  AI_GodView.swift
//  maple-diffusion
//
//  Created by Tilak Shakya on 21/10/23.
//
import SwiftUI
import StoreKit


struct AI_GodView: View {
    @State private var mostrarAlertaDeCompra: Bool = false
    @ObservedObject var subscriptionManager: SubscriptionManager = SubscriptionManager()
    @Binding var dismissView: Bool // Binding to control the full-screen cover
    //@Environment(\.presentationMode) var presentationMode // Access to presentation mode
    @State private var isShowingCustomView = false
    
    
    
    func purchaseSubscription() {
        
        mostrarAlertaDeCompra = true
        
    }
    
    
    
    func userAcceptedSubscription() {
        
        subscriptionManager.subscriptionBuy()
        
    }
    
    func checkSubscription(){
        if subscriptionManager.isSubscribed {
            isShowingCustomView = true
        } else {
            isShowingCustomView = false
        }
    }
    
    
    var body: some View {
        
        //        if subscriptionManager.isSubscribed {
        //            isShowingCustomView = true
        //            // I need to dismiss the current view when i have this value to true
        //        } else {
        
        ZStack {
            
            Color.white.edgesIgnoringSafeArea(.all)
            
            
            
            VStack {
                
                Text("Image creator Pro")
                
                    .font(.system(size: 36, weight: .medium, design: .default))
                
                    .foregroundColor(.black)
                
                    .padding(.top, 132)
                
                    .padding(.leading, 42.45)
                
                Spacer()
                
            }
            
            
            
            VStack(spacing: 20) {
                
                Spacer()
                
                Spacer().frame(height: 85)
                
                
                
                // Aquí supongo que tienes otros elementos como FeatureItem, etc...
                
                
                
                VStack(spacing: 9) {
                    
                    Text("Auto-renews for US$ 19,99/month until canceled")
                    
                        .font(.system(size: 14))
                    
                        .foregroundColor(Color.gray)
                    
                    
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 12)
                        
                            .fill(Color(UIColor(red: 0.20, green: 0.28, blue: 0.96, alpha: 1.0)))
                        
                            .frame(height: 55)
                        
                        
                        
                        Text("Subscribe")
                        
                            .foregroundColor(Color.white)
                        
                            .font(.system(size: 18, weight: .bold))
                        
                    }
                    
                    .padding(.horizontal)
                    
                    .onTapGesture {
                        
                        purchaseSubscription()
                        
                        
                    }
                    
                }
                
                .padding(.bottom, 34)
                
            }
            
        }
        
        .toolbar {
            
            Text("AI God")
            
                .font(.largeTitle)
            
                .bold()
            
                .foregroundColor(.black)
            
                .font(.system(size: 36))
            
        }
        
        .alert(isPresented: $mostrarAlertaDeCompra) {
            
            Alert(title: Text("ChatGPT Plus"),
                  
                  message: Text("""
  
  Premium features
  
  Plus subscribers have access to GPT-4 and our latest beta features.
  
  App Store
  
  
  
  ChatGPT Plus
  
  Suscripción
  
  
  
  USD 19.99 por mes
  
  
  
  Puedes cancelar en cualquier momento en Configuración > Apple ID, por lo menos un día antes de cada fecha de renovación. El plan se renueva automáticamente hasta que se cancele.
  
  """),
                  
                  primaryButton: .default(Text("Aceptar"), action: {
                
                userAcceptedSubscription()
                
            }),
                  
                  secondaryButton: .cancel(Text("Cancelar")))
            
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissAiGodView"))) { notification in
            let transactions = notification.object as! [SKPaymentTransaction]
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased:
                    // Handle a successful purchase
                    Task {
                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second (1 billion nanoseconds)
                        //                        dismissView = true
                        isShowingCustomView = true
                    }
                    //
                    
                case .failed:
                    // Handle a failed purchase
                    print("Payment Status: Failed1")
                    
                case .restored:
                    // Handle a restored purchase
                    print("Payment Status: Restored1")
                    //
                    //                    Task {
                    //                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second (1 billion nanoseconds)
                    //                        dismissView = false
                    //                    }
                    
                    
                default:
                    print("Payment Status: default1")
                    
                    break
                }
            }
        }
        .onAppear(perform: {
            checkSubscription()
        })
        .fullScreenCover(isPresented: $isShowingCustomView) {
            ContentView()
        }
    }
    //    }
}


class SubscriptionManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var productLoadedCompletion: ((SKProduct?) -> Void)?  // Completion closure property
    
    // Change this to your actual product identifier
    let productID = "GOD"
    
    var isSubscribed = false
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func subscriptionBuy() {
        loadProduct(withProductIdentifier: productID) { product in
            if let product = product {
                if SKPaymentQueue.canMakePayments() {
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.default().add(payment)
                }
            } else {
                // Handle product loading error
                print("Failed to load the product.")
            }
        }
    }
    
    func loadProduct(withProductIdentifier productIdentifier: String, completion: @escaping (SKProduct?) -> Void) {
        productLoadedCompletion = completion  // Set the completion closure property
        
        let productIdentifiers: Set<String> = [productIdentifier]
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        
        // Implement SKProductsRequestDelegate methods to handle the product request response.
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            // Product loaded successfully.
            // You can now use the 'product' for purchase.
            isSubscribed = true
            productLoadedCompletion?(product)  // Invoke the completion closure
            
            
            
        } else {
            // Handle product not found
            productLoadedCompletion?(nil)  // Invoke the completion closure with nil
        }
    }
    
    func transactionDone(transactions: [SKPaymentTransaction])
    {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        NotificationCenter.default.post(name: Notification.Name("DismissAiGodView"), object: transactions)
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Handle a successful purchase
                print("Payment Status: Purchased")
                
                
                
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                // Handle a failed purchase
                print("Payment Status: Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
                
                
            case .restored:
                // Handle a restored purchase
                print("Payment Status: Restored")
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                print("Payment Status: default")
                
                break
            }
        }
    }
}


//}
