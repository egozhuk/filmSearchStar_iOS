//
//  FilmCard.swift
//  FilmStars
//
//  Created by Егор Жуков on 14.12.2023.
//

import UIKit

struct FilmCardViewModel: Codable {
    let filmId: Int
    let nameRu: String?
    let nameEn: String?
    let type: String
    let year: String?
    let description: String?
    let filmLength: String?
    let rating: String?
    let ratingVoteCount: Int?
    let posterUrl: URL?
    let posterUrlPreview: URL?
}

class FilmCard: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    private lazy var filmLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 10)
        label.textColor = .black
        return label
    }()
    
    private lazy var yearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 10)
        label.textColor = .black
        return label
    }()
    
    private lazy var starLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 10)
        label.textColor = .black
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
    
    private let model: FilmCardViewModel
    
    init(model: FilmCardViewModel, style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.model = model
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        backgroundColor = .white
        layer.cornerRadius = 16
        titleLabel.text = model.nameRu ?? model.nameEn
        if let length = model.filmLength {
            filmLengthLabel.text = "Длительность: \(length)"
        } else {
            filmLengthLabel.text = "Длительность: Нет данных"
        }
        yearLabel.text = model.year
        if let rating = model.rating {
            starLabel.text = "Оценка: \(rating)"
        } else {
            starLabel.text = "Оценка: Нет данных"
        }
        
        if let imageUrl = model.posterUrlPreview {
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
        
        addSubview(titleLabel)
        addSubview(filmImageView)
        addSubview(filmLengthLabel)
        addSubview(yearLabel)
        addSubview(starLabel)
        
        NSLayoutConstraint.activate([
            filmImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            filmImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            filmImageView.widthAnchor.constraint(equalToConstant: 75),
            filmImageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: filmImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            starLabel.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor, constant: 6),
            starLabel.leadingAnchor.constraint(greaterThanOrEqualTo: filmImageView.trailingAnchor, constant: 12),
            
            filmLengthLabel.topAnchor.constraint(greaterThanOrEqualTo: starLabel.bottomAnchor, constant: 6),
            filmLengthLabel.leadingAnchor.constraint(greaterThanOrEqualTo: filmImageView.trailingAnchor, constant: 12),
            
            yearLabel.topAnchor.constraint(greaterThanOrEqualTo: filmLengthLabel.bottomAnchor, constant: 6),
            yearLabel.leadingAnchor.constraint(greaterThanOrEqualTo: filmImageView.trailingAnchor, constant: 12),
        ])
    }
    
    func configure(with viewModel: FilmCardViewModel) {
        titleLabel.text = model.nameRu ?? model.nameEn
        if let length = model.filmLength {
            filmLengthLabel.text = "Длительность: \(length)"
        } else {
            filmLengthLabel.text = "Длительность: Нет данных"
        }
        yearLabel.text = viewModel.year
        if let rating = model.rating {
            starLabel.text = "Оценка: \(rating)"
        } else {
            starLabel.text = "Оценка: Нет данных"
        }

    }
}
