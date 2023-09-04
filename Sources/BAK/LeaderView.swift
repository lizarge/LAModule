//
//  SwiftUIView.swift
//  
//
//  Created by ankudinov aleksandr on 23.08.2023.
//

import SwiftUI
import FirebaseAuth
import Photos
import PhotosUI
import ExyteMediaPicker
import FirebaseStorage

struct LeaderView: View {
    
    let name = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? ""
    var logo:UIImage?
    var title:String = "Leaderboard"
    var termsUrl:String? = "https://www.freeprivacypolicy.com/live/7dbd55be-25cb-4427-bcf3-4e432b5ec06a"
    
    @State var email = ""
    @State var password = ""
    @State var username = ""
    @State var error = ""
    @State var logined = false
    @State var isRestore = false
    
    @State private var medias: [Media] = []
    @State private var galleryPicker: Bool = false
    
    public var closeBlock:(()->Void)?
    
    @State var avatarUrl = Bundle.module.url(forResource: "nouser", withExtension: "png")
    
    let icon = UIApplication.shared.icon ?? UIImage()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
    var body: some View {
        
        VStack(spacing:0) {
            
            VStack {
                Image(uiImage: icon ).resizable().aspectRatio(contentMode: .fill).frame(width: 150.0).padding().clipShape(Circle())
                Text(title) .font(.custom("Copperplate", fixedSize: 30)).foregroundColor(.purple)
            }.padding(10)
            
            Spacer()
            
            if !logined {
                ProgressView().onAppear{
                    Auth.auth().signInAnonymously{ (result, error) in
                        if error != nil {
                            self.error = error?.localizedDescription ?? "Service Error, Try later."
                        } else {
                            avatarUrl = result?.user.photoURL ?? avatarUrl
                            username = result?.user.displayName ?? ""
                            self.error = ""
                            logined = true
                        }
                    }
                }
                
            } else {
              
                HStack {
                    
                    Button {
                        self.galleryPicker = true
                    } label: {
                        VStack {
                            AsyncImage(
                                url: avatarUrl,
                                content: { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                         .frame(maxWidth: 40, maxHeight: 40)
                                },
                                placeholder: {
                                    ProgressView()
                                }
                            ).clipShape(Circle())
                        }
                        .padding()
                    }
          
                    TextField("Nickname", text: $username).textFieldStyle(.roundedBorder)
                
                   
                }.font(.title2).padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25))
                .sheet(isPresented: $galleryPicker) {
                    MediaPicker(
                        isPresented: $galleryPicker,
                        onChange: { medias in
                            if let media = medias.first, let user = Auth.auth().currentUser {
                                Task {
                                    
                                    guard let data = await media.getData() else {
                                        return
                                    }
                                   
                                    self.avatarUrl = await media.getThumbnailURL()
                                    
                                    let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(user.uid).png")
                                    
                                    _ = profileImgReference.putData(data, metadata: nil) { (metadata, error) in
                                       if let error = error {
                                           self.error = error.localizedDescription
                                       } else {
                                           profileImgReference.downloadURL(completion: { (url, error) in
                                               if let url = url{
                                                   let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                                   changeRequest?.photoURL = url
                                                   changeRequest?.commitChanges { (error) in
                                                       if error != nil {
                                                           self.error = error?.localizedDescription ?? "Service Error, try later"
                                                       }
                                                   }
                                               } else{
                                                   self.error = error?.localizedDescription ?? "Service Error, try later"
                                               }
                                           })
                                       }
                                   }
                            
                                }
                            }
                        }
                    )
                    .showLiveCameraCell()
                    .mediaSelectionLimit(1)
                    .mediaSelectionType(.photo)
                    .mediaSelectionStyle(.checkmark)
                }
                
                Group {
                    Button(action: {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.commitChanges { (error) in
                            if error != nil {
                                self.error = error?.localizedDescription ?? "Service Error, try later"
                            } else {
                                self.closeBlock?()
                            }
                        }
                    }) {
                        Text("Enjoy Game!")
                    }.padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)).background(
                            (username.isEmpty) ? .clear : .yellow).clipShape(Capsule()).disabled(username.isEmpty)
                        .font(.title2).padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25))
                    
                    Spacer()
                    
                    Button(action: {
                        try? Auth.auth().signOut()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                            self.closeBlock?()
                    }
                        
                    }) {
                        Text("Skip and Play")
                    }.foregroundColor(.white).padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)).background(.gray).clipShape(Capsule())
                }
                
               
            }
            
            Spacer()
            
            if !self.logined {
                Button(action: {
                    self.closeBlock?()
                }) {
                    Text("Skip & Play")
                }.foregroundColor(.white).padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)).background(.gray).clipShape(Capsule())
            }
            
            VStack {
                Text(error).font(.footnote).foregroundColor(.red)
                Text(
                    "Enjoy \(name) leaderboard, and compete with other players."
                ).font(.footnote).foregroundColor(.gray).padding(25)
            }
            
            Link("Agree with our Terms & Privacy", destination: URL(string: termsUrl ?? "")!)
                .font(.footnote)
                .foregroundStyle(.gray)
        }.onDisappear(perform: {
            self.closeBlock?()
        })
        
    }
        
}

struct LeaderView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderView(logo: #imageLiteral(resourceName: "MakeCoins"))
    }
}



