//
//  MovieView.swift
//  FilmStarsTests
//
//  Created by Егор Жуков on 14.12.2023.
//

import UIKit

class MovieView: UIViewController {
    
    var filmId: Int = 0
    var nameRu: String? = nil
    var nameEn: String? = nil
    var type: String? = nil
    var year: String? = nil
    var descript: String? = nil
    var filmLength: String? = nil
    var rating: String? = nil
    var ratingVoteCount: Int? = nil
    var posterUrl: URL? = nil
    var isStarFilled: Bool = false
    var index: Int = 0
    var startFromFavourites: Bool = false
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.contentSize = CGSize(width: view.bounds.width, height: 1000)
        return scrollView
    }()
    
    private lazy var filmNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 30)
        label.text = nameRu
        return label
    }()
    
    private lazy var filmEnNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 20)
        label.text = nameEn
        return label
    }()
    
    private lazy var filmYearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 15)
        label.text = year
        return label
    }()
    
    private lazy var filmLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 15)
        label.text = "Длительность: \(filmLength ?? "Нет данных")"
        return label
    }()
    
    private lazy var filmRatingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 15)
        label.text = "Оценка: \(rating ?? "Нет данных")"
        return label
    }()
    
    private lazy var filmRatingCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 15)
        let str = String(ratingVoteCount ?? 0)
        label.text = "Количество отзывов: \(str)"
        return label
    }()
    
    private lazy var filmDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = .systemFont(ofSize: 12)
        label.text = descript
        return label
    }()
    
    private lazy var filmImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    private lazy var webViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    @objc func starButtonTapped() {
        updateStarButton()
    }

    func updateStarButton() {
        if !isStarFilled {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star.fill")
            favourite.append(movies[index])
            isStarFilled = true
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star")
            var ind: Int = 0
            if (startFromFavourites) {
                ind = indexOfMovieWith(filmId: favourite[index].filmId) ?? -1
            } else {
                ind = indexOfMovieWith(filmId: movies[index].filmId) ?? -1
            }
            if (ind != -1) {
                favourite.remove(at: ind)
            }
            isStarFilled = false
        }
        saveFavouriteToUserDefaults(movies: favourite)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        let starButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(starButtonTapped))
        navigationItem.rightBarButtonItem = starButton
        
        if (startFromFavourites) {
            isStarFilled = true
        } else {
            isStarFilled = isMovieInFavourites(filmId: movies[index].filmId)
        }
        
        if isStarFilled {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star.fill")
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star")
        }
        
        if let imageUrl = posterUrl {
            let session = URLSession.shared
            
            let task = session.dataTask(with: imageUrl) { (data, response, error) in
                if let imageData = data, error == nil {
                    if let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.filmImageView.image = image
                        }
                    }
                } else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
            task.resume()
        } else {
            print("URL is nil")
        }
        
        scrollView.addSubview(filmNameLabel)
        scrollView.addSubview(filmEnNameLabel)
        scrollView.addSubview(filmYearLabel)
        scrollView.addSubview(filmLengthLabel)
        scrollView.addSubview(filmRatingLabel)
        scrollView.addSubview(filmRatingCountLabel)
        scrollView.addSubview(filmImageView)
        scrollView.addSubview(filmDescriptionLabel)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            filmImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            filmImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            filmImageView.widthAnchor.constraint(equalToConstant: 120),
            filmImageView.heightAnchor.constraint(equalToConstant: 170),
            
            filmNameLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            filmNameLabel.leadingAnchor.constraint(equalTo: filmImageView.trailingAnchor, constant: 16),
            filmNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filmEnNameLabel.topAnchor.constraint(equalTo: filmNameLabel.bottomAnchor, constant: 4),
            filmEnNameLabel.leadingAnchor.constraint(equalTo: filmImageView.trailingAnchor, constant: 16),
            filmEnNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filmYearLabel.topAnchor.constraint(equalTo: filmEnNameLabel.bottomAnchor, constant: 4),
            filmYearLabel.leadingAnchor.constraint(equalTo: filmImageView.trailingAnchor, constant: 16),
            filmYearLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filmLengthLabel.topAnchor.constraint(equalTo: filmYearLabel.bottomAnchor, constant: 4),
            filmLengthLabel.leadingAnchor.constraint(equalTo: filmImageView.trailingAnchor, constant: 16),
            filmLengthLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filmRatingLabel.topAnchor.constraint(equalTo: filmLengthLabel.bottomAnchor, constant: 4),
            filmRatingLabel.leadingAnchor.constraint(equalTo: filmImageView.trailingAnchor, constant: 16),
            filmRatingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filmRatingCountLabel.topAnchor.constraint(equalTo: filmRatingLabel.bottomAnchor, constant: 4),
            filmRatingCountLabel.leadingAnchor.constraint(equalTo: filmImageView.trailingAnchor, constant: 16),
            filmRatingCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            filmDescriptionLabel.topAnchor.constraint(equalTo: filmRatingCountLabel.bottomAnchor, constant: 40),
            filmDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            filmDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
}
