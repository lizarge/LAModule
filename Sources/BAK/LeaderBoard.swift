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
    
    @AppStorage("1") var name1:String = ""
    @AppStorage("2") var name2:String = ""
    @AppStorage("3") var name3:String = ""
    @AppStorage("4") var name4:String = ""
    @AppStorage("5") var name5:String = ""
    @AppStorage("6") var score:Int = 0
    @AppStorage("7") var rank:Int = 0
     
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
                    .foregroundColor(.black).padding(5)
                }
                
                Spacer()
                
                Text(name.capitalized) .font(.custom("Copperplate", fixedSize: 30)).foregroundColor(.black)
                
                Image(uiImage: icon).resizable().frame(width: 50,height: 50).scaledToFit().clipShape(Circle())
                
                Spacer()
              
                ShareLink(Text(""), item: "My leader rank is #\(rank) on \(name) game!\n\(URL(string: "https://itunes.apple.com/app/id\(appID)")!.absoluteString)")
            
            }.padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
          
            List{
                ItemRow(name: name1, score: "\(score * 2)",avatarUrl: URL(string: "https://i.pravatar.cc/150?u=\(appID)")!)
                ItemRow(name: name2, score: "\(score - 10)",avatarUrl: URL(string: "https://i.pravatar.cc/150?u=\(appID)1")!)
                ItemRow(name: name3, score: "\( Int( Double(score) / 1.3) )",
                        avatarUrl: URL(string: "https://i.pravatar.cc/150?u=\(appID)2")!
                        )
                ItemRow(name: name4, score: "\( Int( Double(score) / 2 - 23) )")
                ItemRow(name: name5, score: "\( Int( Double(score) / 3) + 300 )", avatarUrl: URL(string: "https://i.pravatar.cc/150?u=\(appID)12")!)
                
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
            
        }.onAppear{
            if score == 0 {
                score = Int.random(10000, 50000)
                name1 = Randoms.randomFakeFirstName()
                name2 = Randoms.randomFakeFirstName()
                name3 = Randoms.randomFakeLastName()
                name4 = Randoms.randomFakeFirstName()
                name5 = Randoms.randomFakeLastName()
                
                rank = Int.random(11, 21)
            }
      
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
            Text(score).font(.system(size: 30,design: .rounded)).foregroundColor(.black)
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
