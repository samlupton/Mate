//
//  PostView.swift
//  Mate
//
//  Created by Samuel Lupton on 5/28/23.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

struct PostView: View {
    var body: some View {
        GameView()
    }
}

struct Game: Codable, Hashable {
    let home_team: String
    let away_team: String
    let commence_time: String
    let bookmakers: [Bookmaker]

    struct Bookmaker: Codable, Hashable {
        let title: String
        let markets: [Market]

        struct Market: Codable, Hashable {
            let key: String
            let outcomes: [Outcome]

            struct Outcome: Codable, Hashable {
                let name: String
                let price: Double
            }
        }
    }
}


struct GameView: View {
    @State private var games: [Game] = []
    let mapper = TeamAbbreviationMapper()
    let sports = ["NFL", "NBA", "MLB", "NHL", "PGA", "College Football", "Men's College Basketball", "Women's College Basketball", "Soccer", "WNBA", "Esports", "NASCAR", "Tennis", "MMA", "Boxing", "Disc Golf", "Euro Basketball", "Cricket"]

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(sports, id: \.self) { sport in
                        Button(action: {
                            // Perform action when sport button is tapped
                            // Navigate to the view named after the sport
                            // You can handle the navigation based on your app's navigation mechanism
                            print("Tapped \(sport)")
                        }) {
                            VStack {
                                Image(systemName: sport.iconName)
                                    .frame(width: 40, height: 40)
                                
//                                Text(sport)
//                                    .font(.caption)
//                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle()) // Make the button circular
                        }
                    }
                }
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(games, id: \.commence_time) { game in
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Home: \(game.home_team)")
                                .bold()
                                .lineLimit(1)
                            
                            Text("Away: \((game.away_team))")
                                .bold()
                                .lineLimit(1)
                            VStack {
                                HStack {
                                    //                                Text("Home/Away:")
                                    HStack {}
                                    Spacer()
                                    Text("\(mapper.getAbbreviationForTeam(game.home_team))")
                                        .bold()
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false) // Add fixed width
                                        .font(Font.system(.body, design: .monospaced)) // Use monospaced font
                                    Spacer()
                                    Text("\(mapper.getAbbreviationForTeam(game.away_team))")
                                        .bold()
                                        .lineLimit(1)
                                        .fixedSize(horizontal: true, vertical: false) // Add fixed width
                                        .font(Font.system(.body, design: .monospaced)) // Use monospaced font
                                }
                                ForEach(game.bookmakers, id: \.title) { bookmaker in
                                    HStack() {
                                        VStack{
                                            //                                        let truncatedTitle = String(bookmaker.title.prefix(12))
                                            //                                        let paddedTitle = truncatedTitle.padding(toLength: 20, withPad: " ", startingAt: 0)
                                            
                                            Text("\(bookmaker.title)")
                                                .font(.headline)
                                                .lineLimit(1)
                                        }
                                        
                                        ForEach(bookmaker.markets.flatMap(\.outcomes), id: \.name) { outcome in
                                            HStack {
                                                Spacer()
                                                Text(String(format: "%.0f", outcome.price))
                                                    .font(.subheadline)
                                                    .fixedSize(horizontal: true, vertical: false) // Add fixed width
                                                    .font(Font.system(.body, design: .monospaced)) // Use monospaced font
                                            }
                                            .padding(.vertical, 2)
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
                .onAppear {
                    fetchGames()
                }
            }
        }
    }

    func fetchGames() {
        guard let url = URL(string: "https://api.the-odds-api.com/v4/sports/americanfootball_nfl/odds/?regions=us&oddsFormat=american&apiKey=563a69fa607f4fcf2a77cf89cde34b8c") else {
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let gameResponse = try decoder.decode([Game].self, from: data)

                    let uniqueGames = Array(Set(gameResponse))

                    DispatchQueue.main.async {
                        games = uniqueGames
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
}

extension String {
    var iconName: String {
        switch self {
        case "NFL":
            return "football"
        case "NBA":
            return "basketball"
        case "MLB":
            return "baseball"
        case "NHL":
            return "hockey.puck"
        case "PGA":
            return "figure.golf"
        case "College Football":
            return "football"
        case "Men's College Basketball":
            return "basketball"
        case "Women's College Basketball":
            return "basketball"
        case "Soccer":
            return "soccerball"
        case "WNBA":
            return "basketball"
        case "Esports":
            return "gamecontroller"
        case "NASCAR":
            return "flag.checkered.2.crossed"
        case "Tennis":
            return "tennisball"
        case "MMA":
            return "figure.kickboxing"
        case "Boxing":
            return "figure.boxing"
        case "Disc Golf":
            return "sportscourt"
        case "Euro Basketball":
            return "basketball"
        case "Cricket":
            return "cricket.ball"
        default:
            return "questionmark"
        }
    }
}
