import UIKit

final class TemperatureRangeView: UIView {
    
    private var pendingRange: (min: Double, max: Double, totalMin: Double, totalMax: Double)?
    private let backgroundLine = UIView()
    private let rangeLine = UIView()

    private var rangeLeadingConstraint: NSLayoutConstraint?
    private var rangeWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        backgroundLine.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        backgroundLine.layer.cornerRadius = 2
        backgroundLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundLine)

        rangeLine.backgroundColor = UIColor(hex: "#FFF875")
        rangeLine.layer.cornerRadius = 2
        rangeLine.translatesAutoresizingMaskIntoConstraints = false
        backgroundLine.addSubview(rangeLine)

        NSLayoutConstraint.activate([
            backgroundLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundLine.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundLine.heightAnchor.constraint(equalToConstant: 4)
        ])

        rangeLeadingConstraint = rangeLine.leadingAnchor.constraint(equalTo: backgroundLine.leadingAnchor)
        rangeWidthConstraint = rangeLine.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            rangeLeadingConstraint!,
            rangeLine.centerYAnchor.constraint(equalTo: backgroundLine.centerYAnchor),
            rangeLine.heightAnchor.constraint(equalTo: backgroundLine.heightAnchor),
            rangeWidthConstraint!
        ])
    }

    func updateRange(min: Double, max: Double, totalMin: Double, totalMax: Double) {
         pendingRange = (min, max, totalMin, totalMax)
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let range = pendingRange else { return }

        let totalRange = range.totalMax - range.totalMin
        guard totalRange > 0 else { return }

        let startFraction = CGFloat((range.min - range.totalMin) / totalRange)
        let endFraction = CGFloat((range.max - range.totalMin) / totalRange)
        let rangeWidth = bounds.width

        let leading = rangeWidth * startFraction
        let width = rangeWidth * (endFraction - startFraction)

        rangeLeadingConstraint?.constant = leading
        rangeWidthConstraint?.constant = width
    }
}
