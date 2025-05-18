import UIKit

final class WeatherViewController: UIViewController {

    private let viewModel: WeatherViewModel

    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let minMaxLabel = UILabel()
    private let additionalInfoLabel = UILabel()

    private let dailyTableView = IntrinsicTableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let hourlyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: 60, height: 100)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private let infoStackView = UIStackView()
    private let rootStackView = UIStackView()

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        styleLabels()
        viewModel.delegate = self
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(hex: "#2A89AB").cgColor, UIColor(hex: "#8CF9D8").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)

        infoStackView.axis = .vertical
        infoStackView.alignment = .center
        infoStackView.spacing = 8
        [cityLabel, temperatureLabel, conditionLabel, minMaxLabel, additionalInfoLabel, ].forEach {
            $0.textAlignment = .center
            infoStackView.addArrangedSubview($0)
        }

        dailyTableView.register(DailyForecastCell.self, forCellReuseIdentifier: DailyForecastCell.identifier)
        dailyTableView.dataSource = self
        dailyTableView.delegate = self
        dailyTableView.rowHeight = UITableView.automaticDimension
        dailyTableView.estimatedRowHeight = 60
        dailyTableView.isScrollEnabled = false
        dailyTableView.separatorStyle = .none
        dailyTableView.layer.cornerRadius = 16
        dailyTableView.clipsToBounds = true
        dailyTableView.backgroundColor = .clear

        hourlyCollectionView.dataSource = self
        hourlyCollectionView.delegate = self
        hourlyCollectionView.register(HourlyForecastCell.self, forCellWithReuseIdentifier: HourlyForecastCell.reuseId)
        hourlyCollectionView.showsHorizontalScrollIndicator = false
        hourlyCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        hourlyCollectionView.backgroundColor = .clear

        rootStackView.axis = .vertical
        rootStackView.spacing = 16
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootStackView)

        rootStackView.addArrangedSubview(infoStackView)
        rootStackView.addArrangedSubview(hourlyCollectionView)
        rootStackView.addArrangedSubview(dailyTableView)
        
        setupAccessibilityIdentifiers()
    }
    
    private func styleLabels() {
        cityLabel.font = .systemFont(ofSize: 34, weight: .bold)
        temperatureLabel.font = .systemFont(ofSize: 64, weight: .thin)
        conditionLabel.font = .systemFont(ofSize: 20)
        minMaxLabel.font = .systemFont(ofSize: 16)
        additionalInfoLabel.font = .systemFont(ofSize: 14)
        additionalInfoLabel.textColor = .secondaryLabel

        [cityLabel, temperatureLabel, conditionLabel, minMaxLabel, additionalInfoLabel].forEach {
            $0.textAlignment = .center
        }
    }
    
    private func setupAccessibilityIdentifiers() {
        cityLabel.accessibilityIdentifier = "cityLabel"
        temperatureLabel.accessibilityIdentifier = "currentTempLabel"
        conditionLabel.accessibilityIdentifier = "weatherDescriptionLabel"
        minMaxLabel.accessibilityIdentifier = "minMaxLabel"
        additionalInfoLabel.accessibilityIdentifier = "additionalInfoLabel"
        hourlyCollectionView.accessibilityIdentifier = "hourlyForecastCollectionView"
        dailyTableView.accessibilityIdentifier = "dailyForecastTableView"
        activityIndicator.accessibilityIdentifier = "loadingIndicator"
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            rootStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -16),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func updateUI() {
        cityLabel.text = viewModel.locationTitle
        temperatureLabel.text = viewModel.temperatureText
        conditionLabel.text = viewModel.conditionText
        minMaxLabel.text = viewModel.minMaxTemperatureText
        additionalInfoLabel.text = viewModel.additionalDescriptionText

        hourlyCollectionView.reloadData()
        dailyTableView.reloadData()
    }
    
    private func setLoading(_ loading: Bool) {
        loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension WeatherViewController: WeatherViewModelDelegate {
    func didStartLoading() {
        setLoading(true)
    }

    func didFinishLoading() {
        setLoading(false)
    }

    func didUpdateWeather() {
        updateUI()
    }

    func didFailWithError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.viewModel.loadWeather()
        })
        present(alert, animated: true)
    }
}

extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dailyForecasts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DailyForecastCell.identifier, for: indexPath) as? DailyForecastCell else {
            return UITableViewCell()
        }
        let forecast = viewModel.dailyForecasts[indexPath.row]
        cell.configure(with: forecast, minWeekTemp: viewModel.minWeekTemp, maxWeekTemp: viewModel.maxWeekTemp)
        return cell
    }
}

extension WeatherViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.hourlyForecast.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCell.reuseId, for: indexPath) as? HourlyForecastCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModel.hourlyForecast[indexPath.item])
        return cell
    }
}
