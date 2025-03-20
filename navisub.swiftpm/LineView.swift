//
//  LineView.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/1/26.
//

import SwiftUI
import MapKit
import CoreLocation

@available(iOS 17.0, *)
struct LineView:View {
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    
    var body: some View {
        VStack {
            HStack() {
                Text("\(env.isEnglish ? env.selectedLine!.name_eg : env.selectedLine!.name_cn)")
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
            List(db.getStationByLine(line: env.selectedLine), id: \.id) { station in
                Button(action: {
                    env.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                    ))
                    if (env.selectedDir == "S") {
                        env.setStart(station: station)
                        env.path.removeLast()
                        env.path.removeLast()
                    }
                    else if (env.selectedDir == "E"){
                        env.setEnd(station: station)
                        env.path.removeLast()
                        env.path.removeLast()
                    }
                }) {
                    HStack {
                        Text(env.isEnglish ? station.name_eg : station.name_cn)
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .frame(maxWidth: UIScreen.main.bounds.width - (CGFloat(station.lines.count) * 40) - 80, alignment: .leading)
                            .fixedSize(horizontal: true, vertical: false)
                        Spacer()
                        ForEach(station.lines, id: \.id) { line in
                            ZStack {
                                Circle()
                                    .fill(line.color)
                                    .frame(width: 30, height: 30)
                                Text("\(line.abbreviation_eg)")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
            }
        }
        .navigationBarHidden(true)
    }
}
