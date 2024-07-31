//
//  FeedRecomendedFilterDetailsCategoriesViewController.swift
//  ElloAppUI
//
//

import UIKit

class FeedRecomendedFilterDetailsCategoriesViewController: FeedRecomendedFilterDetailsBaseViewController {
    // MARK: - Properties
    private var categories: [String] = [] {
        didSet {
            createSnapshot(with: categories)
        }
    }
    let allCategories = "All Categories"
    private var filteredCategories: [String] = []
    private var selectedCategory: String?
    var selectedCategoryHandler: ((String) -> Void)?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Channel category"
        
        getCategories()
    }
    
    // MARK: - IBActions
    override func saveButtonTapped(_ sender: UIBarButtonItem) {
        searchController.dismiss(animated: true) { [weak self] in
            self?.dismiss(animated: true) {
                if let selectedCategory = self?.selectedCategory {
                    if selectedCategory == self?.allCategories {
                        self?.selectedCategoryHandler?("")
                    } else {
                        self?.selectedCategoryHandler?(selectedCategory)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    override func filterContentForSearchText(_ searchText: String) {
        filteredCategories = categories.filter {
            $0.lowercased().contains(searchText.lowercased())
        }
        
        if isFiltering {
            createSnapshot(with: filteredCategories)
        } else {
            createSnapshot(with: categories)
        }
    }
    
    // MARK: - Network Manager calls
    func getCategories() {
        Task {
            var categories = await requestManager.getCategories(with: context)
            categories.insert(allCategories, at: 0)
            
            self.categories = categories
        }
    }
}

extension FeedRecomendedFilterDetailsCategoriesViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        
        if isFiltering {
            selectedCategory = filteredCategories[safe: indexPath.row]
        } else {
            selectedCategory = categories[safe: indexPath.row]
        }
        
        saveButtonTapped(UIBarButtonItem())
    }
}
