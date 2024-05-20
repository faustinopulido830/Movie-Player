//
//  SearchMovieViewController.swift
//  Movie Player
//
//  Created by Faustino Pulido Sarmiento on 18/05/24.
//

import UIKit

class FilterMovieViewController: UIViewController {
    
    
    @IBOutlet weak var adultFilter: UISegmentedControl!
    @IBOutlet weak var languageFilter: UISegmentedControl!
    @IBOutlet weak var sorterVoteAverage: UISegmentedControl!
    var needFilterLanguage:Bool = false
    var filterLanguage = ""
    var shouldShowAdult:Bool = false
    var needSortVoteAverage:Bool = false
    var sortedMax:Bool = false
    var categoryToSearch:String = ""
    var dataService = MovieDataService()
    var topic:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataService.delegate = self
    }
    
    private func search() {
        Task{
            await dataService.getMovieVideos(topic:topic)
        }
    }
    
    func filterByLanguage(movieList:[Result], shouldFilter:Bool, language:String) -> [Result]{
        var filteredMovies:[Result] = []
        if shouldFilter {
            movieList.forEach { movie in
                if movie.originalLanguage == language{
                    filteredMovies.append(movie)
                }
            }
            return filteredMovies
        }
        return movieList
    }
    func sortVoteAverage(movieList:[Result], shouldSort:Bool, max:Bool)-> [Result]{
        if shouldSort {
            var movies = [Result]()
            if max {
                movies = movieList.sorted { $0.voteAverage > $1.voteAverage }
            } else {
                movies = movieList.sorted { $0.voteAverage < $1.voteAverage }
            }
            return movies
        } else {
            return movieList
        }
    }
    
    func shouldShowAdult(movieList: [Result], showAdult: Bool) -> [Result] {
        return movieList.filter { movie in
            let shouldInclude = showAdult ? movie.adult : !movie.adult
            return shouldInclude
        }
    }
    
    @IBAction func adultFilterAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            shouldShowAdult = false
        case 1:
            shouldShowAdult = true
        default:
            print ("Default")
        }
    }
    
    @IBAction func languageFilterAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            needFilterLanguage = false
        case 1:
            needFilterLanguage = true
            filterLanguage = sender.titleForSegment(at: 1)!
        case 2:
            needFilterLanguage = true
            filterLanguage = sender.titleForSegment(at: 2)!
        case 3:
            needFilterLanguage = true
            filterLanguage = sender.titleForSegment(at: 3)!
        case 4:
            needFilterLanguage = true
            filterLanguage = sender.titleForSegment(at: 4)!
        case 5:
            needFilterLanguage = true
            filterLanguage = sender.titleForSegment(at: 5)!
        case 6:
            needFilterLanguage = true
            filterLanguage = sender.titleForSegment(at: 6)!
        default:
            print ("Default")
        }
    }
    
    @IBAction func sorterVoteAverageAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            needSortVoteAverage = false
        case 1:
            needSortVoteAverage = true
            sortedMax = false
        case 2:
            needSortVoteAverage = true
            sortedMax = true
        default:
            print ("Default")
        }
    }
    
    @IBAction func didTapFilterButton(_ sender: Any) {
        search()
    }
    
}
extension FilterMovieViewController:MovieDataServiceDelegate{
    func showMovies(movieList: [Result]) {
        DispatchQueue.main.async {
            if let vc = self.presentingViewController as? MoviesViewController {
                self.dismiss(animated: true){ [self] in
                    var filteredMovies : [Result] = []
                    filteredMovies = shouldShowAdult(movieList: movieList, showAdult: shouldShowAdult)
                    filteredMovies = sortVoteAverage(movieList: filteredMovies, shouldSort: needSortVoteAverage, max: sortedMax)
                    filteredMovies = filterByLanguage(movieList: filteredMovies, shouldFilter: needFilterLanguage, language: filterLanguage)
                    vc.movies = filteredMovies
                    vc.moviesCollection.reloadData()
                }
            }
        }
    }
    
    func showError(error: String) {
        print("Error: \(error)")
    }
}
