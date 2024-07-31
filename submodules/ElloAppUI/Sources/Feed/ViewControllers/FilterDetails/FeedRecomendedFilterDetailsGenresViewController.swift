//
//  FeedRecomendedFilterDetailsGenresViewController.swift
//  ElloAppUI
//
//

import UIKit

class FeedRecomendedFilterDetailsGenresViewController: FeedRecomendedFilterDetailsBaseViewController {
    // MARK: - Properties
    private var genres: [String] = [] {
        didSet {
            createSnapshot(with: genres)
        }
    }
    let allGenres = "All Genres"
    private var filteredGenres: [String] = []
    private var selectedGenre: String?
    var selectedGenreHandler: ((String) -> Void)?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Genres"
        
        getGenres()
    }
    
    // MARK: - IBActions
    override func saveButtonTapped(_ sender: UIBarButtonItem) {
        searchController.dismiss(animated: true) { [weak self] in
            self?.dismiss(animated: true) {
                if let selectedGenre = self?.selectedGenre {
                    if selectedGenre == self?.allGenres {
                        self?.selectedGenreHandler?("")
                    } else {
                        self?.selectedGenreHandler?(selectedGenre)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    override func filterContentForSearchText(_ searchText: String) {
        filteredGenres = genres.filter {
            $0.lowercased().contains(searchText.lowercased())
        }
        
        if isFiltering {
            createSnapshot(with: filteredGenres)
        } else {
            createSnapshot(with: genres)
        }
    }
    
    // MARK: - Network Manager calls
    func getGenres() {
        Task {
            var genres = await requestManager.getGenres(with: context)
            genres.insert(allGenres, at: 0)
            
            self.genres = genres
        }
    }
}

extension FeedRecomendedFilterDetailsGenresViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        
        if isFiltering {
            selectedGenre = filteredGenres[safe: indexPath.row]
        } else {
            selectedGenre = genres[safe: indexPath.row]
        }
        
        saveButtonTapped(UIBarButtonItem())
    }
}
