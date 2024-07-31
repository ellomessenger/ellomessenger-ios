//
//  FeedRecomendedViewController.swift
//  ElloAppUI
//
//

import UIKit
import ELBase
import ElloAppCore
import AccountContext
import Postbox

class FeedRecomendedViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, FoundPeer>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, FoundPeer>
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var allFilterControl: FeedRecommendedFilterControl!
    @IBOutlet var newFilterControl: FeedRecommendedFilterControl!
    @IBOutlet var courseFilterControl: FeedRecommendedFilterControl!
    @IBOutlet var paidFilterControl: FeedRecommendedFilterControl!
    @IBOutlet var freeFilterControl: FeedRecommendedFilterControl!
    @IBOutlet var countryFilterControl: FeedRecommendedFilterControl!
    @IBOutlet var categoryFilterControl: FeedRecommendedFilterControl!
    @IBOutlet var genreFilterControl: FeedRecommendedFilterControl!
    
    // MARK: - Properties
    private lazy var dataSource = makeDataSource()
    private var filters: [FeedRecomendedFilterItem] {
        FeedRecomendedFilterItem.filterItems
    }
    var foundUsers: [FoundPeer] = [] {
        didSet {
            createSnapshot()
        }
    }
    var context: AccountContext?
    private let dataService = DataService()
    private let requestManager = RequestsManager()
    var showChatControllerHandler: ((_ channelPeerId: PeerId) -> Void)?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dataService.delegate = self
        allFilterControl.isSelected = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureCollectionView()
        createSnapshot()
        
        getRecomendations()
    }
    
    // MARK: - Set up
    private func configureCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createCollectionViewLayout()
    }
    
    // MARK: - IBActions
    @IBAction func allFilterTapped(_ sender: FeedRecommendedFilterControl) {
        allFilterControl.isSelected = false
        newFilterControl.isSelected = false
        courseFilterControl.isSelected = false
        paidFilterControl.isSelected = false
        freeFilterControl.isSelected = false
        
        switch sender {
        case allFilterControl:
            dataService.changeField(.all)
        case newFilterControl:
            dataService.changeField(.isNew)
        case courseFilterControl:
            dataService.changeField(.isCourse)
        case paidFilterControl:
            dataService.changeField(.isPaid)
        case freeFilterControl:
            dataService.changeField(.isFree)
        default: break
        }
        
        sender.isSelected = true
    }
    
    @IBAction func countryFilterTapped(_ sender: FeedRecommendedFilterControl) {
        showCountriesFilter()
    }
    
    @IBAction func categoryFilterTapped(_ sender: FeedRecommendedFilterControl) {
        showCategoriesFilter()
    }
    
    @IBAction func genreFilterTapped(_ sender: FeedRecommendedFilterControl) {
        showGenresFilter()
    }
    
    // MARK: - Actions
    private func makeDataSource() -> DataSource {
        DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeedRecommendedChannelCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? FeedRecommendedChannelCollectionViewCell
            cell?.configure(with: item, context: self?.context)
            
            return cell
        }
    }
    
    private func channelsLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(70.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(70.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8.0
//        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 10, bottom: 10, trailing: 10)
        
        return section
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout(section: channelsLayoutSection())
    }
    
    func createSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(foundUsers, toSection: 0)
        dataSource.apply(snapshot)
    }
    
    func searchChannelDidChange(text: String) {
        dataService.changeField(.q(text))
    }
        
    // MARK: - Navigation
    private func showCountriesFilter() {
        guard let context else { return }
        let controller = UIStoryboard(
            name: "ELFeedRecomendedFilterDetails",
            bundle: nil
        ).instantiateViewController(identifier: "FeedRecomendedFilterDetailsBaseViewController") { coder in
            FeedRecomendedFilterDetailsCountriesViewController(coder: coder, context: context)
        }
        controller.selectedCountryHandler = { [weak self] country in
            self?.countryFilterControl.titleLabel.text = country.name
            self?.dataService.changeField(.country(country.countryCodes.first?.code ?? "", country.name))
        }
        
        showFiltersController(with: controller)
    }
    
    private func showCategoriesFilter() {
        guard let context else { return }
        let controller = UIStoryboard(
            name: "ELFeedRecomendedFilterDetails",
            bundle: nil
        ).instantiateViewController(identifier: "FeedRecomendedFilterDetailsBaseViewController") { coder in
            FeedRecomendedFilterDetailsCategoriesViewController(coder: coder, context: context)
        }
        controller.selectedCategoryHandler = { [weak self, weak controller] category in
            if category.isEmpty {
                self?.categoryFilterControl.titleLabel.text = controller?.allCategories
            } else {
                self?.categoryFilterControl.titleLabel.text = category
            }
            self?.genreFilterControl.isHidden = category != "Music"
            if self?.genreFilterControl.isHidden == true {
                self?.dataService.changeField(.genre(""))
                self?.genreFilterControl.titleLabel.text = "All Genres"
            }
            self?.dataService.changeField(.category(category))
        }
        
        showFiltersController(with: controller)
    }
    
    private func showGenresFilter() {
        guard let context else { return }
        
        let controller = UIStoryboard(
            name: "ELFeedRecomendedFilterDetails",
            bundle: nil
        ).instantiateViewController(identifier: "FeedRecomendedFilterDetailsBaseViewController") { coder in
            FeedRecomendedFilterDetailsGenresViewController(coder: coder, context: context)
        }
        controller.selectedGenreHandler = { [weak self, weak controller] genre in
            if genre.isEmpty {
                self?.genreFilterControl.titleLabel.text = controller?.allGenres
            } else {
                self?.genreFilterControl.titleLabel.text = genre
            }
            self?.dataService.changeField(.genre(genre))
        }
        
        showFiltersController(with: controller)
    }
    
    private func showFiltersController(with controller: UIViewController) {
        let rootController = UIStoryboard(
            name: "ELFeedRecomendedFilterDetails",
            bundle: nil
        ).instantiateInitialViewController() as? UINavigationController
        rootController?.viewControllers = [controller]
        
        if let rootController { show(rootController, sender: self) }
    }
    
    // MARK: - Network Manager calls
    func getRecomendations(page: Int = 0) {
        guard let context else { return }
        
        Task {
            let foundUsers = await self.requestManager.getRecomendations(
                with: context,
                query: self.dataService.data.q,
                isNew: self.dataService.data.isNew,
                isPaid: self.dataService.data.isPaid,
                isCourse: self.dataService.data.isCourse,
                isFree: self.dataService.data.isFree,
                country: self.dataService.data.country.code,
                category: self.dataService.data.category,
                genre: self.dataService.data.genre,
                page: page
            )
            self.foundUsers = foundUsers
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FeedRecomendedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let channel = dataSource.itemIdentifier(for: indexPath)?.peer as? ElloAppChannel {
            showChatControllerHandler?(channel.id)
        }
    }
}

extension FeedRecomendedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        guard indexPaths.last?.row ?? 0 >= 20 else { return }
//        
//        if indexPaths.last?.row == dataSource.collectionView(collectionView, numberOfItemsInSection: 0) - 1,
//            let row = indexPaths.last?.row {
//            let page = Int(row / 20)
//            getRecomendations(page: page)
//        }
    }
}

// MARK: - DataServiceDelegate
extension FeedRecomendedViewController: DataServiceDelegate {
    func dataServiceDidUpdateData(_ newData: DataModel) {
        getRecomendations()
    }
}
