//
//  SwiftUIView.swift
//
//
//  Created by ankudinov aleksandr on 30.08.2023.
//

import SwiftUI
import SwiftUI
import FirebaseAuth
import Photos
import PhotosUI
import ExyteMediaPicker
import FirebaseStorage


 struct LeaderBoard: View {
    
    var closeBlock:(()->Void)?
    var deleteBlock:(()->Void)?
    let appID:String
     
    let name = (Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String) ?? "Leaderboard"
    let icon = UIApplication.shared.icon ?? UIImage()
     
    var body: some View {
        VStack {
            HStack {
                
                Button {
                    self.closeBlock?()
                } label: {

                Image(systemName:"arrow.backward.circle")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.black)
                    
                }
                
                Spacer()
                
                Text(name.capitalized) .font(.custom("Copperplate", fixedSize: 30)).foregroundColor(.purple)
                
                Image(uiImage: icon).resizable().frame(width: 50,height: 50).scaledToFit().clipShape(Circle())
                
                Spacer()
              
                ShareLink(Text(""), item: "My leader rank is #11 on \(name) game!\n\(URL(string: "https://itunes.apple.com/app/id\(appID)")!.absoluteString)")
            
            }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
          
            List{
                ItemRow(name: "Unknown", score: "532243",avatarUrl: URL(string: "https://i.pravatar.cc/150?u=a042581f4se290267204d")!)
                ItemRow(name: "bob", score: "423233",avatarUrl: URL(string: "https://i.pravatar.cc/150?u=a04f2581f4e290267204d")!)
                ItemRow(name: "test", score: "420874",
                        avatarUrl: URL(string: "https://i.pravatar.cc/150?u=a042581f4e29s0262704d")!
                        )
                ItemRow(name: "test", score: "119629",avatarUrl: URL(string: "https://i.pravatar.cc/150?u=a042581f4edd290267204d")!)
                ItemRow(name: "Test", score: "113029")
                
                Button {
                    self.deleteBlock?()
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete leaderboard").foregroundColor(.gray)
                        Image(systemName: "trash").renderingMode(.template).foregroundColor(.gray)
                       
                    }
                }.listRowSeparator(.hidden).listRowBackground(Color.clear).background(.clear)
            }.listRowBackground(Color.clear).background(.clear)
            
            }
            
         
    }
}

struct ItemRow : View {
    var name:String
    var score:String
    
    @State var avatarUrl = Bundle.module.url(forResource: "nouser", withExtension: "png")
    
    var body: some View {
    
        HStack {
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
                ).clipShape(Circle()).padding(10)
            }
            Text(name).font(.system(size: 30,design: .rounded))
            Spacer()
            Text(score).font(.system(size: 30,design: .rounded)).foregroundColor(.purple)
        }
        .listRowSeparator(.hidden).listRowBackground(Color.clear).background(.clear)
        
    }
}

public struct LeaderBoard_Previews: PreviewProvider {
    public static var previews: some View {
        LeaderBoard(appID: "")
    }
}


extension UIApplication {
    var icon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? NSDictionary,
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? NSDictionary,
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? NSArray,
            // First will be smallest for the device class, last will be the largest for device class
            let lastIcon = iconFiles.lastObject as? String,
            let icon = UIImage(named: lastIcon) else {
                return nil
        }

        return icon
    }
}
