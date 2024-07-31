//
//  FeedRecomendedFilterDetailsBaseViewController.swift
//  ElloAppUI
//
//

import UIKit
import AccountContext

enum Section {
    case main
}
private let reuseIdentifier = "FeedRecomendedFilterDetailsCollectionViewCell"
class FeedRecomendedFilterDetailsBaseViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // MARK: - Properties
    let context: AccountContext
    let requestManager = RequestsManager()
    let searchController = UISearchController(searchResultsController: nil)
    private var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Life cycle
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder: NSCoder, context: AccountContext) {
        self.context = context
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        collectionView.setCollectionViewLayout(getLayout(), animated: false)
    }
    
    // MARK: - Set up
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    func getLayout() -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.separatorConfiguration.bottomSeparatorInsets.leading = .zero
        config.backgroundColor = UIColor(hexString: "#F6F6F6")
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView,
                   cellProvider: { (collectionView, indexPath, item) -> UICollectionViewListCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FeedRecomendedFilterDetailsCollectionViewCell else {
                fatalError("Cannot create cell")
            }
            
            cell.configure(item: item)
//            cell.accessories = [.checkmark()]
            return cell
        })
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Actions
    func createSnapshot(with items: [AnyHashable]) {
        var initialSnapshot = Snapshot()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(items, toSection: .main)
        
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }
    
    func filterContentForSearchText(_ searchText: String) { }
}

// MARK: - UICollectionViewDelegate
extension FeedRecomendedFilterDetailsBaseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        saveButton.isEnabled = true
    }
}

extension FeedRecomendedFilterDetailsBaseViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            filterContentForSearchText(text)
        }
    }
}
