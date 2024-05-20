//
//  ViewController.swift
//  Movie Player
//
//  Created by Faustino Pulido Sarmiento on 18/05/24.
//

import UIKit
import Kingfisher
import AVKit

class MoviesViewController: UIViewController {
    
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var categoryMovies: UISegmentedControl!
    @IBOutlet weak var moviesCollection: UICollectionView!
    @IBOutlet weak var searchButton: UIButton!
    var movies: [Result] = []
    var dataService = MovieDataService()
    var category = "popular"
    override func viewDidLoad() {
        super.viewDidLoad()
        moviesCollection.delegate = self
        moviesCollection.dataSource = self
        dataService.delegate = self
        getMovies(category: category)
        setupCollection()
    }
    
    private func setupCollection() {
        moviesCollection.collectionViewLayout = UICollectionViewFlowLayout()
        if let flowLayout = moviesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    func getMovies(category:String) {
        Task {
            await dataService.getMovieVideos(topic:category)
        }
    }
    
    @IBAction func didTapSearchButton(_ sender: UIButton) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SearchMovieViewController") as! FilterMovieViewController
        vc.topic = category
        if let sheet = vc.presentationController as? UISheetPresentationController {
            sheet.detents =  [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
        
    }
    
    @IBAction func categorySelectedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            category = "popular"
            movieTitle.text = "Popular's movies"
        case 1:
            category = "top_rated"
            movieTitle.text = "Top rated's movies"
        default:
            print ("Default")
        }
        Task {
            await dataService.getMovieVideos(topic:category)
        }
    }
}

extension MoviesViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviesCell", for: indexPath) as! MoviesCell
        if let urlImage =   URL(string: "https://image.tmdb.org/t/p/original/\(movies[indexPath.row].backdropPath)") {
            cell.movieImage.kf.setImage(with: urlImage)
            cell.movieImage.layer.cornerRadius = 25
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let defaultVideo =
        "https://player.vimeo.com/external/342571552.hd.mp4?s=6aa6f164de3812abadff3dde86d19f7a074a8a66&profile_id=175&0auth2_token_id=57447761"
        guard let url = URL(string: "https://player.vimeo.com/external/342571552.hd.mp4?s=6aa6f164de3812abadff3dde86d19f7a074a8a66&profile_id=175&0auth2_token_id=57447761") else { return }
        let avPlayer = AVPlayer(url: url)
        let avController = AVPlayerViewController()
        avController.player = avPlayer
        present (avController, animated: true) {
            avPlayer.play ()
        }
    }
}
extension MoviesViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 200)
    }
}
extension MoviesViewController:MovieDataServiceDelegate {
    func showMovies(movieList: [Result]) {
        self.movies = movieList
        DispatchQueue.main.async {
            self.moviesCollection.reloadData()
        }
    }
    func showError(error: String) {
        print("Error: \(error)")
    }
}
