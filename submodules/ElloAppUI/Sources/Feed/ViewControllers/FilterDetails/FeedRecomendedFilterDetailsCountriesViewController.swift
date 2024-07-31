//
//  FeedRecomendedFilterDetailsCountriesViewController.swift
//  ElloAppUI
//
//

import UIKit
import ElloAppCore

class FeedRecomendedFilterDetailsCountriesViewController: FeedRecomendedFilterDetailsBaseViewController {
    // MARK: - IBOutlets
    
    // MARK: - Properties
    private var countries: [Country] = [] {
        didSet {
            createSnapshot(with: countries)
        }
    }
    let allCountries = Country(
        id: "",
        name: "All Countries",
        localizedName: nil,
        countryCodes: [],
        hidden: false
    )
    private var filteredCountries: [Country] = []
    private var selectedCountry: Country?
    var selectedCountryHandler: ((Country) -> Void)?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your country"
        
        getCountries()
    }
    
    // MARK: - IBActions
    override func saveButtonTapped(_ sender: UIBarButtonItem) {
        searchController.dismiss(animated: true) { [weak self] in
            self?.dismiss(animated: true) {
                if let selectedCountry = self?.selectedCountry {
                    self?.selectedCountryHandler?(selectedCountry)
                }
            }
        }
    }
    
    // MARK: - Actions
    override func filterContentForSearchText(_ searchText: String) {
        filteredCountries = countries.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
        
        if isFiltering {
            createSnapshot(with: filteredCountries)
        } else {
            createSnapshot(with: countries)
        }
    }
    
    // MARK: - Network Manager calls
    func getCountries() {
        Task {
            var countries = await requestManager.getCountries(with: context)
            countries.insert(allCountries, at: 0)
            
            self.countries = countries
        }
    }
}

extension FeedRecomendedFilterDetailsCountriesViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didSelectItemAt: indexPath)
        
        if isFiltering {
            selectedCountry = filteredCountries[safe: indexPath.row]
        } else {
            selectedCountry = countries[safe: indexPath.row]
        }
        
        saveButtonTapped(UIBarButtonItem())
    }
}
