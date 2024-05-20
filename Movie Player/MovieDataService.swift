//
//  MovieDataService.swift
//  Movie Player
//
//  Created by Faustino Pulido Sarmiento on 19/05/24.
//

import Foundation

protocol MovieDataServiceDelegate {
    func showMovies(movieList:[Result])
    func showError(error:String)
}
struct MovieDataService {
    
    var delegate: MovieDataServiceDelegate?
    func getMovieVideos(topic:String) async {
        do {
            guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(topic)") else {
                print("Error when create url")
                return}
            
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            let queryItems: [URLQueryItem] = [
              URLQueryItem(name: "include_adult", value: "true"),
              URLQueryItem(name: "include_video", value: "false"),
              URLQueryItem(name: "language", value: "en-US"),
              URLQueryItem(name: "page", value: "1"),
              URLQueryItem(name: "sort_by", value: "popularity.desc"),
            ]
            components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.timeoutInterval = 10
            request.allHTTPHeaderFields = [
              "accept": "application/json",
              "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyYTg2MmY1ZTI3YjFlNzQ3ZTUyMGFkOTc0ZTEyMzExMSIsInN1YiI6IjY2NDk1NTczOTU5OTEyYjNkOTdhNjJiMiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.oZduMwW7O-WsLoZ2z4KsceBC_SnG8SQLi4giZia0lhU"
            ]
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                fatalError("Error fetching data")
            }
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(ResponseMovieModel.self, from: data)
            let movieList = decodedData.results
            delegate?.showMovies(movieList: movieList)
        } catch {
            print ("Debug \(#line): error \(error.localizedDescription)")
        }
    }
    
    
}
