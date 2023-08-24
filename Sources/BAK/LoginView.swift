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

struct LoginView: View {
    
    var logo:UIImage?
    var title:String = "Game Сommunity"
    var hint:String = "By signup to our game community, you get additional bonuses in game and help us make your game more personalized and groovy."
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
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  
    var body: some View {
        
        VStack(spacing:0) {
            
            Group {
                Image(uiImage: logo ?? #imageLiteral(resourceName: "MakeCoins") ).resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 200,maxHeight: 200)
                Text(title) .font(.custom("Copperplate", fixedSize: 30)).foregroundColor(.purple)
            }
            
            Spacer()
            
            HStack {
                Text(error).font(.footnote).foregroundColor(.red)
            }
            
            if !logined {
                
                Group{
                    TextField("Email", text: $email).textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
                
                    Button(action: {
                        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                                    if error != nil {
                                        
                                        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                                            if error != nil {
                                                self.error = error?.localizedDescription ?? "Service Error, try later"
                                                self.isRestore = true
                                            } else {
                                                avatarUrl = result?.user.photoURL ?? avatarUrl
                                                username = result?.user.displayName ?? ""
                                                self.error = ""
                                                logined = true
                                            }
                                        }
                        
                                    } else {
                                        avatarUrl = result?.user.photoURL ?? avatarUrl
                                        username = result?.user.displayName ?? ""
                                        self.error = ""
                                        logined = true
                                    }
                                }
                    }) {
                        Text("Come In")
                    }.padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)).background(
                        (email.isEmpty || password.isEmpty) ? .clear : .blue).clipShape(Capsule()).disabled(email.isEmpty || password.isEmpty)
                    
                    if isRestore {
                        Button(action: {
                            Auth.auth().sendPasswordReset(withEmail: email){ (error) in
                                if error != nil {
                                    self.error = error?.localizedDescription ?? "Service Error, try later"
                                    self.isRestore = true
                                } else {
                                    self.error = "Check your postal address please."
                                    self.isRestore = false
                                }
                            }
                        }) {
                            Text("Restore Password")
                        }.padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)).background(
                            (email.isEmpty || password.isEmpty) ? .clear : .blue).clipShape(Capsule()).disabled(email.isEmpty || password.isEmpty)
                    }
                    
                }.font(.title2).padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25))
            } else {
              
                Group{
                    
                    Button {
                        self.galleryPicker = true
                    } label: {
                        VStack {
                            AsyncImage(
                                url: avatarUrl,
                                content: { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fill)
                                         .frame(maxWidth: 80, maxHeight: 80)
                                },
                                placeholder: {
                                    ProgressView()
                                }
                            ).clipShape(Circle())
                        }
                        .padding()
                    }
          
                    TextField("Nickname", text: $username).textFieldStyle(.roundedBorder)
                
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
                        Text("Start Game!")
                    }.padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)).background(
                            (username.isEmpty) ? .clear : .purple).clipShape(Capsule()).disabled(username.isEmpty)
                    
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
            }
            
            Spacer()
            
            if !self.logined {
                Button(action: {
                    self.closeBlock?()
                }) {
                    Text("Continue anonymously")
                }.foregroundColor(.white).padding(EdgeInsets(top: 5, leading: 25, bottom: 5, trailing: 25)).background(.gray).clipShape(Capsule())
            }
            
            Text(hint).font(.footnote).foregroundColor(.gray).padding(25)
            Link("Login is agree with our Terms & Privacy", destination: URL(string: "https://www.freeprivacypolicy.com/live/7dbd55be-25cb-4427-bcf3-4e432b5ec06a")!)
                .font(.footnote)
                .foregroundStyle(.gray)
        }.onDisappear(perform: {
            self.closeBlock?()
        })
        
    }
        

}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(logo: #imageLiteral(resourceName: "MakeCoins"))
    }
}



