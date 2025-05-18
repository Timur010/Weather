import UIKit

final class HourlyForecastCell: UICollectionViewCell {
    static let reuseId = "HourlyForecastCell"
    
    private let timeLabel = UILabel()
    private let iconImageView = UIImageView()
    private let tempLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.backgroundColor = UIColor(hex: "#6FCCEE")
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textAlignment = .center
        
        iconImageView.contentMode = .scaleAspectFit
        
        tempLabel.font = .systemFont(ofSize: 16, weight: .medium)
        tempLabel.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [timeLabel, iconImageView, tempLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            iconImageView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with hour: Hour) {
        timeLabel.text = formatHour(hour.time)
        tempLabel.text = "\(Int(hour.tempC))°"
        if let url = URL(string: "https:\(hour.condition.icon)") {
            self.iconImageView.load(from: url)
        }
    }
    
    private func formatHour(_ isoString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = formatter.date(from: isoString) {
            let hourFormatter = DateFormatter()
            hourFormatter.dateFormat = "HH:mm"
            return hourFormatter.string(from: date)
        }
        return "--:--"
    }
}
