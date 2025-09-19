//
//  CountryCell.swift
//  WalmartAssessment
//
//  Created by Arpit Mallick on 9/19/25.
//

import UIKit

final class CountryCell: UITableViewCell {
    static let reuseID = "CountryCell"

    private let nameRegionLabel = UILabel()
    private let codeLabel = UILabel()
    private let capitalLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func bind(_ country: Country) {
        nameRegionLabel.text = "\(country.name), \(country.region)"
        codeLabel.text = country.code
        capitalLabel.text = country.capital
        accessibilityLabel = "\(country.name), \(country.region). Code \(country.code). Capital \(country.capital)"
    }

    private func configure() {
        selectionStyle = .none
        [nameRegionLabel, codeLabel, capitalLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.adjustsFontForContentSizeCategory = true
        }
        nameRegionLabel.font = .preferredFont(forTextStyle: .headline)
        codeLabel.font = .preferredFont(forTextStyle: .headline)
        codeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        capitalLabel.font = .preferredFont(forTextStyle: .subheadline)

        let topRow = UIStackView(arrangedSubviews: [nameRegionLabel, codeLabel])
        topRow.axis = .horizontal
        topRow.alignment = .firstBaseline
        topRow.spacing = 8
        topRow.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [topRow, capitalLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
