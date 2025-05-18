import UIKit

final class DailyForecastCell: UITableViewCell {
    
    static let identifier = "DailyForecastCell"
    
    private let dayLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let iconView = UIImageView()
    private let minTempLabel = UILabel()
    private let maxTempLabel = UILabel()
    private let tempRangeView = TemperatureRangeView()
    
    private let stack = UIStackView()
    private let tempStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = UIColor(hex: "#6FCCEE")

        dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentHuggingPriority(.required, for: .vertical)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        
        minTempLabel.font = .systemFont(ofSize: 14, weight: .medium)
        minTempLabel.textColor = UIColor(hex: "#0877FF")
        
        minTempLabel.textAlignment = .center
        minTempLabel.translatesAutoresizingMaskIntoConstraints = false
        minTempLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        maxTempLabel.font = .systemFont(ofSize: 14, weight: .medium)
        maxTempLabel.textColor = UIColor(hex: "#FFFFFF")
        maxTempLabel.textAlignment = .center
        maxTempLabel.translatesAutoresizingMaskIntoConstraints = false
        maxTempLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        tempRangeView.translatesAutoresizingMaskIntoConstraints = false
        
        let textStack = UIStackView(arrangedSubviews: [dayLabel, descriptionLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        
        tempStack.axis = .horizontal
        tempStack.alignment = .center
        tempStack.distribution = .equalSpacing
        tempStack.spacing = 8
        
        tempStack.addArrangedSubview(minTempLabel)
        tempStack.addArrangedSubview(tempRangeView)
        tempStack.addArrangedSubview(maxTempLabel)
        
        minTempLabel.setContentHuggingPriority(.required, for: .horizontal)
        maxTempLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(tempStack)
        
        contentView.addSubview(stack)
        
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tempRangeView.heightAnchor.constraint(equalToConstant: 10),
            tempRangeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
    func configure(with model: DailyForecast, minWeekTemp: Double, maxWeekTemp: Double) {
        dayLabel.text = formattedDay(from: model.date)
        descriptionLabel.text = model.conditionText
        
        minTempLabel.text = "\(Int(model.tempMin))°"
        maxTempLabel.text = "\(Int(model.tempMax))°"
        
        iconView.image = nil
        if let url = model.iconURL {
            iconView.load(from: url)
        }
        
        tempRangeView.updateRange(
            min: model.tempMin,
            max: model.tempMax,
            totalMin: minWeekTemp,
            totalMax: maxWeekTemp
        )
    }
    
    private func formattedDay(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        if Calendar.current.isDateInToday(date) {
            return "Сегодня"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Завтра"
        }
        
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }
}
