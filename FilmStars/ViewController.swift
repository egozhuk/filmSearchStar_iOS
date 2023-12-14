import UIKit

var movies: [SearchResponse.Movie] = []
var favourite: [SearchResponse.Movie] = []
var apiKey: String = "643139e0-bf1b-4a93-b062-6391abe593ec"

func isMovieInFavourites(filmId: Int) -> Bool {
    return favourite.contains { $0.filmId == filmId }
}

func indexOfMovieWith(filmId: Int) -> Int? {
    if let index = favourite.firstIndex(where: { $0.filmId == filmId }) {
        return index
    }
    return -1
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    let cellSpacingHeight: CGFloat = 12
    var fileContents: String = ""

    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.placeholder = "Введите название фильма:"
        return textField
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilmCard.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.backgroundColor = .systemGray6
        return tableView
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Найти", for: .normal)
        button.backgroundColor = .black
        button.tintColor = .green
        button.layer.cornerRadius = 13
        button.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        return button
    }()
    
    @objc
    func searchButtonAction() {
        if let searchText = searchTextField.text, !searchText.isEmpty {
            searchMovies(withName: searchText)
            tableView.reloadData()
            view.endEditing(true)
            saveMoviesToUserDefaults(movies: movies)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchText = searchTextField.text, !searchText.isEmpty {
            searchMovies(withName: searchText)
            tableView.reloadData()
            view.endEditing(true)
            saveMoviesToUserDefaults(movies: movies)
        }
        return true
    }
    
    @objc
    func favouriteButtonTapped() {
        navigationController?.pushViewController(FavouriteView(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        let titleLabel = UILabel()
        titleLabel.text = "Filmifly"
        titleLabel.textColor = UIColor.red
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        navigationItem.titleView = titleLabel
        
        let favouriteButton = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(favouriteButtonTapped))
        navigationItem.rightBarButtonItem = favouriteButton
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        movies = loadMoviesFromUserDefaults()
        favourite = loadFavouriteFromUserDefaults()
        
        searchTextField.delegate = self
     
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            
            searchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 12),
            searchButton.widthAnchor.constraint(equalToConstant: 80),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
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
        let film = movies[indexPath.row]
        
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
        
        let cell = FilmCard(model: viewModel, style: .default, reuseIdentifier: "CellIdentifier")
        
        tableView.separatorColor = UIColor.clear
        
        cell.layer.borderWidth = 4.0
        cell.layer.borderColor = UIColor.systemGray6.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilm = movies[indexPath.row]
        
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
        viewController.startFromFavourites = false
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func searchMovies(withName name: String) {
        guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error encoding search term")
            return
        }
        
        let urlString = "https://kinopoiskapiunofficial.tech/api/v2.1/films/search-by-keyword?keyword=\(encodedName)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(SearchResponse.self, from: data)
                movies = response.films
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    saveMoviesToUserDefaults(movies: movies)
                }
            } catch {
                print("Error: \(error)")
            }
        }
        
        task.resume()
    }

}

struct SearchResponse: Codable {
    let films: [Movie]

    struct Movie: Codable, Equatable {
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

    struct Country: Codable {
        let country: String?
    }

    struct Genre: Codable {
        let genre: String?
    }
}

func saveMoviesToUserDefaults(movies: [SearchResponse.Movie]) {
    let userDefaults = UserDefaults.standard
    do {
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(movies)
        userDefaults.set(encodedData, forKey: "movies")
        userDefaults.synchronize()
    } catch {
        print("Ошибка при кодировании данных: \(error.localizedDescription)")
    }
}

func loadMoviesFromUserDefaults() -> [SearchResponse.Movie] {
    let userDefaults = UserDefaults.standard
    if let savedData = userDefaults.data(forKey: "movies") {
        do {
            let decoder = JSONDecoder()
            let loadedMovies = try decoder.decode([SearchResponse.Movie].self, from: savedData)
            return loadedMovies
        } catch {
            print("Ошибка при раскодировании данных: \(error.localizedDescription)")
        }
    }
    return []
}

func saveFavouriteToUserDefaults(movies: [SearchResponse.Movie]) {
    let userDefaults = UserDefaults.standard
    do {
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(favourite)
        userDefaults.set(encodedData, forKey: "fav")
        userDefaults.synchronize()
    } catch {
        print("Ошибка при кодировании данных: \(error.localizedDescription)")
    }
}

func loadFavouriteFromUserDefaults() -> [SearchResponse.Movie] {
    let userDefaults = UserDefaults.standard
    if let savedData = userDefaults.data(forKey: "fav") {
        do {
            let decoder = JSONDecoder()
            let loadedMovies = try decoder.decode([SearchResponse.Movie].self, from: savedData)
            return loadedMovies
        } catch {
            print("Ошибка при раскодировании данных: \(error.localizedDescription)")
        }
    }
    return []
}
