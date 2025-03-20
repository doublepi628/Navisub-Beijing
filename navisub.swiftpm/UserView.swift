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
    let utilNameEG = ["Star", "History"]
    let utilNameCN = ["收藏", "历史"]
    let helpImagesEG = [SampleImage(url: "select-in-map", caption: "Select a subway station from the map"),
                      SampleImage(url: "select-by-search", caption: "Select a subway station through search"),
                      SampleImage(url: "select-in-line", caption: "Select a subway station from the Line page"),
                      SampleImage(url: "navigation", caption: "Get detailed navigation information"),
                      SampleImage(url: "view-detail", caption: "Get detailed station information")]
    let helpImagesCN = [SampleImage(url: "select-in-map-CN", caption: "从地图上选择一个地铁站"),
                      SampleImage(url: "select-by-search-CN", caption: "通过搜索选择一个地铁站"),
                      SampleImage(url: "select-in-line-CN", caption: "从地铁线路页面选择一个地铁站"),
                      SampleImage(url: "navigation-CN", caption: "获取地铁导航具体信息"),
                      SampleImage(url: "view-detail-CN", caption: "获取地铁站的具体信息")]
    
    var body: some View {
        VStack {
            HStack() {
                Text(env.isEnglish ? "User" : "用户")
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
                        .padding(.leading, 20)
                        Spacer()
                        Button(action: {
                            if UserDefaults.standard.bool(forKey: "English") {
                                UserDefaults.standard.set(false, forKey: "English")
                            }
                            else {
                                UserDefaults.standard.set(true, forKey: "English")
                            }
                            env.isEnglish.toggle()
                        }) {
                            Image(systemName: "globe")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 20)
                    }.frame(width: UIScreen.main.bounds.width))
            }
            VStack(spacing: 3) {
                HStack {
                    Text(env.isEnglish ? "Utility 🔧" : "功能 🔧")
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
                List(env.isEnglish ? utilNameEG : utilNameCN, id: \.self) { name in
                    Button(action: {
                        if (name == "Star" || name == "收藏") {
                            env.path.append("StarView")
                        }
                        else if (name == "History" || name == "历史") {
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
                    Text(env.isEnglish ? "Help 🙋" : "帮助 🙋")
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
                    ForEach(env.isEnglish ? helpImagesEG : helpImagesCN) { img in
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
