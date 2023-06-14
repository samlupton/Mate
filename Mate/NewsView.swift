import SwiftUI

struct NewsResponse: Codable {
    let header: String
    let articles: [Article]
}

struct Article: Codable {
    let headline: String
    let description: String
    let published: String
    let links: ArticleLinks
    let images: [ArticleImage]
    // Add other properties as needed
}

struct ArticleLinks: Codable {
    let web: ArticleLink?
}

struct ArticleLink: Codable {
    let href: String
}

struct ArticleImage: Codable {
    let url: String
    let width: Int
    let height: Int
    // Add other properties as needed
}

class NewsViewModel: ObservableObject {
    @Published var newsData: NewsResponse? 
    
    func fetchNewsData() {
        guard let url = URL(string: "https://site.api.espn.com/apis/site/v2/sports/football/college-football/news") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.newsData = newsResponse
                }
            } catch {
                print("Error decoding API response: \(error)")
            }
        }.resume()
    }
}

struct NewsView: View {
    @ObservedObject private var viewModel = NewsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let newsData = viewModel.newsData {
                    // Display the news articles using the fetched data
                    ForEach(newsData.articles, id: \.headline) { article in
                        VStack(alignment: .leading, spacing: 8) {
                            if let articleImage = article.images.first {
                                // Display the article image
                                AsyncImage(url: URL(string: articleImage.url)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(10) // Apply corner radius here
                                    case .failure:
                                        Image(systemName: "photo")
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                                .padding(.bottom, 8)
                            }
                            
                            Text(article.headline)
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            
                            Text(article.description)
                                .font(.body)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true) // Allow the text to wrap and expand vertically
                            
                            Text(article.published)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let webLink = article.links.web {
                                Button(action: {
                                    if let url = URL(string: webLink.href) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("Read More")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // Display a loading indicator or error message
                    Text("Loading...")
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            viewModel.fetchNewsData()
        }
    }
}

struct NewsView_Previews: PreviewProvider {
    static var previews: some View {
        NewsView()
    }
}
