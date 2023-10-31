//
//  ImageSearchView.swift
//  maple-diffusion
//
//  Created by Tilak Shakya on 21/10/23.
//

import SwiftUI

struct ImageSearchView: View {
    @ObservedObject var viewModel = ImageSearchViewModel()
    @State private var searchText: String = ""
    @State private var images: [UIImage] = []
    @State private var selectedImage: IdentifiableImage?
    @State private var activeSheet: ActiveSheet?
    @State private var isGeneratingImages: Bool = false
    @State private var progress: Double = 0.0
    @State private var isAIGodViewPresented: Bool = false


    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    if searchText.isEmpty {
                        Text("Your words, visualized.")

                            .foregroundColor(Color.gray.opacity(0.6))

                            .font(.system(size: 30, weight: .thin, design: .default))
                            .padding(.top, 280)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {


                        ForEach(images.indices, id: \.self) { index in
                            Image(uiImage: images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    selectedImage = IdentifiableImage(image: images[index])

                                }
                        }
                    }
                    .padding()
                    .padding(.top, 28.3465)

                }


                if isGeneratingImages {
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding([.leading, .trailing])
                }
                SearchBar(placeholder: "Describe your image", text: $searchText) {
                    searchImage()
                }
            }
            .navigationBarTitle(" ", displayMode: .inline)
            .navigationBarItems(trailing:


                                    HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    resetConversation()

                }) {
                    Image(systemName: "ellipsis")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(20)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .frame(width: 10, height: 60)
                }
                Spacer().frame(width: 20)
            }

            )
        }
        .onAppear {
            viewModel.configure()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {

            case .image:

                if let selectedImage = selectedImage {


                    ImageDetailView(image: selectedImage.image)

                }

            case .subscription:
                AI_GodView(dismissView: $isAIGodViewPresented)

                    .environment(\.colorScheme, .light)
            }
        }

    }

    func searchImage() {
        if images.isEmpty {
            Task {
                self.isGeneratingImages = true

                self.images = await viewModel.generateImages(prompt: searchText) { newProgress in
                    self.progress = newProgress
                }
                self.isGeneratingImages = false
                self.activeSheet = .subscription
            }
        }
    }


    func resetConversation() {
        // Restablecer el estado de las imágenes a un array vacío
        images.removeAll()
        // Realizar cualquier otra acción necesaria para reiniciar la conversación

        // ...
    }



    struct ImageDetailView: View {
        let image: UIImage

        var body: some View {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                    .edgesIgnoringSafeArea(.all)
            }
        }
    }





    struct SearchBar: View {

        var placeholder: String
        @Binding var text: String
        var action: () -> Void

        var body: some View {
            HStack(spacing: 12) {
                TextField(placeholder, text: $text)
                    .padding(.leading, 8)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                    .foregroundColor(.black)
                
                
                Button(action: action) {
                    
                    Image(systemName: "arrow.up.circle.fill")
                    
                        .resizable()
                    
                        .frame(width: 29, height: 29)
                    
                        .foregroundColor(.black)
                    
                        .background(Color.white)
                    
                        .clipShape(Circle())
                }
                .padding(.trailing, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }




    struct FeatureItem: View {
        var icon: String
        var title: String
        var description: String
        var iconColor: Color
        var yOffset: CGFloat
        var iconWidth: CGFloat
        var iconHeight: CGFloat
        var titleOffset: CGFloat = 0
        var xOffset: CGFloat = 0

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconWidth, height: iconHeight)
                    .foregroundColor(iconColor)
                    .frame(width: 35, alignment: .center)
                    .padding(.trailing, 10)

                    .offset(x: xOffset, y: yOffset)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .bold()
                        .font(.system(size: 18))
                        .padding(.leading, titleOffset)
                    
                    Text(description)
                        .foregroundColor(Color.gray.opacity(1))
                        .font(.system(size: 19))
                        .lineLimit(4)
                        .padding(.leading, titleOffset)
                        .padding(.trailing, 17.14)
                }
            }
            .alignmentGuide(.leading) { d in d[.leading] }
            .padding(.leading, 8)
        }
    }
}

struct ImageSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSearchView()
    }
}
