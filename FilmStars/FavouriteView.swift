//
//  FavouriteView.swift
//  FilmStars
//
//  Created by Егор Жуков on 14.12.2023.
//

import UIKit

class FavouriteView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellSpacingHeight: CGFloat = 12
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilmCard.self, forCellReuseIdentifier: "FavIdentifier")
        tableView.backgroundColor = .systemGray6
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        
        let titleLabel = UILabel()
        titleLabel.text = "Favourite"
        titleLabel.textColor = UIColor.red
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        navigationItem.titleView = titleLabel
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourite.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }
    
    func tableView(_ tableView: UITableView, spacingForSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let film = favourite[indexPath.row]
        
        let viewModel = FilmCardViewModel(
            filmId: film.filmId,
            nameRu: film.nameRu,
            nameEn: film.nameEn,
            type: film.type,
            year: film.year,
            description: film.description,
            filmLength: film.filmLength,
            rating: film.rating,
            ratingVoteCount: film.ratingVoteCount,
            posterUrl: film.posterUrl,
            posterUrlPreview: film.posterUrlPreview
        )
        
        let cell = FilmCard(model: viewModel, style: .default, reuseIdentifier: "FavIdentifier")
        
        tableView.separatorColor = UIColor.clear
        
        cell.layer.borderWidth = 4.0
        cell.layer.borderColor = UIColor.systemGray6.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilm = favourite[indexPath.row]
        
        let viewController = MovieView()
        viewController.filmId = selectedFilm.filmId
        viewController.nameRu = selectedFilm.nameRu
        viewController.nameEn = selectedFilm.nameEn
        viewController.type = selectedFilm.type
        viewController.year = selectedFilm.year
        viewController.descript = selectedFilm.description
        viewController.filmLength = selectedFilm.filmLength
        viewController.rating = selectedFilm.rating
        viewController.ratingVoteCount = selectedFilm.ratingVoteCount
        viewController.posterUrl = selectedFilm.posterUrl
        viewController.index = indexPath.row
        viewController.startFromFavourites = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
