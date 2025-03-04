//
//  UserView.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/2/21.
//

import SwiftUI


struct SampleImage: Identifiable {
    var id = UUID()
    var url: String
    var caption: String
}

@available(iOS 17.0, *)
struct UserView: View {
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    let utilName = ["Star", "History"]
    let helpImages = [SampleImage(url: "select-in-map", caption: "Select a subway station from the map"),
                      SampleImage(url: "select-by-search", caption: "Select a subway station through search"),
                      SampleImage(url: "select-in-line", caption: "Select a subway station from the Line page"),
                      SampleImage(url: "navigation", caption: "Get detailed navigation information"),
                      SampleImage(url: "view-detail", caption: "Get detailed station information")]
    
    var body: some View {
        VStack {
            HStack() {
                Text("User")
                    .font(.system(size: 22))
                    .frame(alignment: .center)
                    .background(Color.white)
                    .padding(10)
                    .overlay(HStack{
                        Button(action: {
                            env.path.removeLast()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.gray)
                        }
                    }.offset(x: 20-UIScreen.main.bounds.width/2))
            }
            VStack(spacing: 3) {
                HStack {
                    Text("Utility 🔧")
                        .font(.system(size: 30))
                        .bold()
                        .padding(.top, 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal)
                List(utilName, id: \.self) { name in
                    Button(action: {
                        if (name == "Star") {
                            env.path.append("StarView")
                        }
                        else if (name == "History") {
                            env.path.append("HistoryView")
                        }
                    }) {
                        HStack {
                            Text(name)
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(height: 130)
                HStack {
                    Text("Help 🙋")
                        .font(.system(size: 30))
                        .bold()
                        .padding(.top, 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                TabView {
                    ForEach(helpImages) { img in
                        VStack(spacing: 0) {
                            Text(img.caption)
                            Image(img.url)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 5)
                                .padding()
                        }
                    }
                }
                .tabViewStyle(.page)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(Color(red: 240/255.0, green: 240/255.0, blue: 245/255.0))
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(true)
            
    }
}
