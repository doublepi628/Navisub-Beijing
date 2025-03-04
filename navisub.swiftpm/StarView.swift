//
//  StarView.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/1/13.
//

import SwiftUI

@available(iOS 17.0, *)
struct StarView: View {
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    
    var body: some View {
        VStack {
            HStack() {
                Text("Star")
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
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(db.stars.reversed(), id: \.self) { star in
                        Button(action: {
                            env.selectedStart = db.stationMap[star.start_id]
                            env.selectedEnd = db.stationMap[star.end_id]
                            env.path.append("RouteView")
                        }) {
                            HStack {
                                Text("\(db.stationMap[star.start_id]!.name_eg)")
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
                                Text("\(db.stationMap[star.end_id]!.name_eg)")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                    .frame(height: 50)
                                    .frame(width: UIScreen.main.bounds.width / 2 - 80, alignment: .trailing)
                                    .padding(.trailing, 20)
                            }
                            .frame(width: UIScreen.main.bounds.width-40, height: 70)
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
