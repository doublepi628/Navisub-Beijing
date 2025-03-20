//
//  SearchView.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/1/13.
//

import SwiftUI
import MapKit
import CoreLocation

@available(iOS 17.0, *)
struct SearchView: View {
    @State private var searchText = ""
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    
    var filteredStations: [Station] {
            if searchText.isEmpty {
                return db.stations
            }
            else {
                return db.stations.filter { $0.name_eg.localizedCaseInsensitiveContains(searchText) || $0.name_cn.localizedCaseInsensitiveContains(searchText) }
            }
        }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    env.path.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                        .padding(10)
                }
                TextField(env.isEnglish ? "Search a Station Here" : "请输入车站名", text: $searchText)
                    .font(.system(size: 22))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: UIScreen.main.bounds.width-100, height: 60)
                    .background(Color.white)
                    .cornerRadius(10)
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(10)
            }
            if searchText.isEmpty {
                List(db.lines, id: \.id) { line in
                    Button(action: {
                        env.selectedLine = line
                        env.path.append("LineView")
                    }) {
                        HStack {
                            Text(env.isEnglish ? line.name_eg : line.name_cn)
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            else {
                List(filteredStations, id: \.id) { station in
                    Button(action: {
                        if (env.selectedDir == "S") {
                            env.setStart(station: station)
                            env.path.removeLast()
                        }
                        else if (env.selectedDir == "E"){
                            env.setEnd(station: station)
                            env.path.removeLast()
                        }
                        env.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                        ))
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
        }
        .navigationBarHidden(true)
    }
}

