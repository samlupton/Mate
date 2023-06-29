struct TeamAbbreviationMapper {
    enum TeamAbbreviation {
        case unknown
        
        var abbreviation: String {
            switch self {
            case .unknown:
                return "UNK"
            }
        }
    }

    func getAbbreviationForTeam(_ teamName: String) -> String {
        let lowercaseTeamName = teamName.lowercased()
        
        // Use a switch statement or if-else statements to map the team name to the abbreviation
        switch lowercaseTeamName {
        case "arizona cardinals":
            return "ARI"
        case "atlanta falcons":
            return "ATL"
        case "baltimore ravens":
            return "BAL"
        case "buffalo bills":
            return "BUF"
        case "carolina panthers":
            return "CAR"
        case "chicago bears":
            return "CHI"
        case "cincinnati bengals":
            return "CIN"
        case "cleveland browns":
            return "CLE"
        case "dallas cowboys":
            return "DAL"
        case "denver broncos":
            return "DEN"
        case "detroit lions":
            return "DET"
        case "green bay packers":
            return "GB"
        case "houston texans":
            return "HOU"
        case "indianapolis colts":
            return "IND"
        case "jacksonville jaguars":
            return "JAX"
        case "kansas city chiefs":
            return "KC"
        case "las vegas raiders":
            return "LV"
        case "los angeles chargers":
            return "LAC"
        case "los angeles rams":
            return "LAR"
        case "miami dolphins":
            return "MIA"
        case "minnesota vikings":
            return "MIN"
        case "new england patriots":
            return "NE"
        case "new orleans saints":
            return "NO"
        case "new york giants":
            return "NYG"
        case "new york jets":
            return "NYJ"
        case "philadelphia eagles":
            return "PHI"
        case "pittsburgh steelers":
            return "PIT"
        case "san francisco 49ers":
            return "SF"
        case "seattle seahawks":
            return "SEA"
        case "tampa bay buccaneers":
            return "TB"
        case "tennessee titans":
            return "TEN"
        case "washington commanders":
            return "WAS"
        default:
            return TeamAbbreviation.unknown.abbreviation
        }
    }
}
