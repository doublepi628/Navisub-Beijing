//
//  HistoryView.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/1/13.
//

import SwiftUI

@available(iOS 17.0, *)
struct HistoryView: View {
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    
    var body: some View {
        VStack {
            HStack() {
                Text(env.isEnglish ? "History" : "历史")
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
                            db.deleteAllHistory()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 20)
                    }.frame(width: UIScreen.main.bounds.width))
            }
            ScrollView {
                VStack() {
                    ForEach(db.historys.reversed(), id: \.self) { history in
                        Button(action: {
                            env.selectedStart = db.stationMap[history.start_id]
                            env.selectedEnd = db.stationMap[history.end_id]
                            env.path.append("RouteView")
                        }) {
                            VStack(spacing: 0) {
                                HStack {
                                    Spacer()
                                    Text("\(history.time)")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 20)
                                        .padding(.top, 5)
                                    
                                }
                                HStack {
                                    Text("\(env.isEnglish ? db.stationMap[history.start_id]!.name_eg : db.stationMap[history.start_id]!.name_cn)")
                                        .font(.system(size: 18))
                                        .foregroundColor(.black)
                                        .frame(height: 50)
                                        .frame(width: UIScreen.main.bounds.width / 2 - 80, alignment: .leading)
                                        .padding(.leading, 20)
                                    
                                    Spacer()
                                    Image(systemName: "arrow.forward.circle")
                                        .font(.system(size: 25))
                                        .foregroundColor(.green)
                                        .padding(10)
                                    Spacer()
                                    Text("\(env.isEnglish ? db.stationMap[history.end_id]!.name_eg : db.stationMap[history.end_id]!.name_cn)")
                                        .font(.system(size: 18))
                                        .foregroundColor(.black)
                                        .frame(height: 50)
                                        .frame(width: UIScreen.main.bounds.width / 2 - 80, alignment: .trailing)
                                        .padding(.trailing, 20)
                                }
                                Spacer()
                                    .frame(height: 10)
                                
                            }
                            .frame(width: UIScreen.main.bounds.width-40, height: 80)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.top, 5)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(Color(red: 240/255.0, green: 240/255.0, blue: 245/255.0))
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationBarHidden(true)
    }
}
