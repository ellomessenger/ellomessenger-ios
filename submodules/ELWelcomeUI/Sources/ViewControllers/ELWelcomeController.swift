//
//  ELWelcomeController.swift
//  _idx_ELWelcomeUI_DAE25A34_ios_min11.0
//
//

import UIKit

class ELWelcomeController: UIPageViewController {
    // MARK: - Public
    public var onTapStart: (() -> Void)?
    public var onTapLangSelect: (() -> Void)?
    
    // MARK: - Properties
    private let initialPage = 0
    private var pages: [UIViewController] = []
    private let pageControl = UIPageControl()
    private let bundle = Bundle(for: ELWelcomeController.self)
    
    private var chooseLangButton: UIButton = {
        let chooseLangButton = UIButton()
        
        chooseLangButton.setTitle("WelcomeChooseLanguage".localized, for: .normal)
        chooseLangButton.setTitleColor(.white, for: .normal)
        chooseLangButton.titleLabel?.font = UIFont.Custom.sfProDisplay(ofSize: 16, weight: .regular)
        chooseLangButton.translatesAutoresizingMaskIntoConstraints = false
        // EM-2743
        chooseLangButton.isHidden = true
        
        return chooseLangButton
    }()
    
    private var startButton: UIButton = {
        let startButton = UIButton()
        
        startButton.backgroundColor = .white
        startButton.layer.cornerRadius = 18
        startButton.setTitle("WelcomeStart".localized, for: .normal)
        startButton.setTitleColor(.darkText, for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        return startButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        style()
    }
    
    // MARK: - Setup
    private func setupData() {
        dataSource = self
        delegate = self
        
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        
        for i in 0...1 {
            let storyboard = UIStoryboard(name: "WelcomeUI", bundle: bundle)
            let firstContentVC = storyboard.instantiateViewController(withIdentifier: "WelcomeSlideView\(i)")
            pages.append(firstContentVC)
            
            setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func style() {
        setupUI()
        pageControl.pageIndicatorTintColor = .white
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage
        pageControl.pageIndicatorTintColor = .white
        setIndicatorImage(initialPage)
        
        for index in 0..<pages.count {
            setIndicatorImage(index)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.35, green: 0.6, blue: 0.97, alpha: 1)
        
        chooseLangButton.addTarget(self, action: #selector(chooseLangTaped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(onStartTaped), for: .touchUpInside)
        
        view.addSubview(chooseLangButton)
        view.addSubview(startButton)
        view.addSubview(pageControl)
        
        
        let startButtonBottomConstraint = startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        startButtonBottomConstraint.priority = .init(rawValue: 999)
        NSLayoutConstraint.activate([
            chooseLangButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chooseLangButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            startButton.heightAnchor.constraint(equalToConstant: 54),
            startButtonBottomConstraint,
            startButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16.0),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 11),
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -16)
        ])
    }
    
    private func setIndicatorImage(_ dataCount: Int) {
        let activeDotImage = UIImage(named: "active_page_control", in: bundle, compatibleWith: nil)
        let inactiveDotImage = UIImage(named: "inactive_page_control", in: bundle, compatibleWith: nil)
        for idx in 0...dataCount {
            if idx == pageControl.currentPage {
                pageControl.setIndicatorImage(activeDotImage, forPage: idx)
            } else {
                pageControl.setIndicatorImage(inactiveDotImage, forPage: idx)
            }
        }
        pageControl.setNeedsLayout()
    }
    
    // MARK: - Actions
    @objc func pageControlTapped(_ sender: UIPageControl) {
        setViewControllers([pages[sender.currentPage]], direction: sender.currentPage == 0 ? .reverse : .forward, animated: true) { [weak self] _ in
            self?.setIndicatorImage(sender.numberOfPages - 1)
        }
    }
    
    @objc func onStartTaped() {
        onTapStart?()
    }
    
    @objc func chooseLangTaped() {
        onTapLangSelect?()
    }
    
}

// MARK: - UIPageViewControllerDataSource
extension ELWelcomeController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        
        setIndicatorImage(currentIndex-1)
        return pages[currentIndex-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex + 1 < pages.count else { return nil }
        
        setIndicatorImage(currentIndex+1)
        return pages[currentIndex+1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension ELWelcomeController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }
        pageControl.currentPage = currentIndex
        
        if completed {
            for (index, _) in self.pages.enumerated() {
                let inactiveDotImage = UIImage(named: "inactive_page_control", in: self.bundle, compatibleWith: nil)
                
                self.pageControl.setIndicatorImage(inactiveDotImage, forPage: index)
                self.setIndicatorImage(currentIndex)
            }
        }
    }
}

// MARK: - UIPageViewController actions
extension UIPageViewController {
    
    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let currentPage = viewControllers?[0] else { return }
        guard let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentPage) else { return }
        
        setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
    }
    
    func goToPreviousPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let currentPage = viewControllers?[0] else { return }
        guard let prevPage = dataSource?.pageViewController(self, viewControllerBefore: currentPage) else { return }
    
        setViewControllers([prevPage], direction: .forward, animated: animated, completion: completion)
    }
    
    func goToSpecificPage(index: Int, ofViewControllers pages: [UIViewController]) {
        setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
    }
}
