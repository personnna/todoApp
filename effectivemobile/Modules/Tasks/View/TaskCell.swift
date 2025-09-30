//
//  TaskCell.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import UIKit
import SnapKit

class TaskCell: UITableViewCell {
    
    static let reuseIdentifier = "TaskCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .appFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let dateCreated: UILabel = {
        let label = UILabel()
        label.text = "23/09/2025"
        label.textColor = .fiftyPercentWhite
        label.font = .appFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        setHighlighted(false, animated: false)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = true
        selectionStyle = .none
        setupView()
        setupConstraints()
        self.selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        selectionStyle = .none
        fatalError("init(coder:) has not been implemented")
//        isUserInteractionEnabled = true
    }

    private func setupView() {
        setHighlighted(false, animated: true)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateCreated)
        contentView.addSubview(checkboxButton)
        contentView.backgroundColor = .clear
        checkboxButton.setImage(UIImage(named: "Icon"), for: .normal)
        checkboxButton.setImage(UIImage(named: "checkbox"), for: .selected)
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)

    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(checkboxButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(checkboxButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
        }
        dateCreated.snp.makeConstraints{ make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(6)
            make.leading.equalTo(checkboxButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(12)
        }
        checkboxButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(24)
            //make.trailing.equalTo(titleLabel.snp.leading).offset(8)
        }
    }
    
    @objc private func checkboxTapped() {
            checkboxButton.isSelected.toggle()
            
            if checkboxButton.isSelected {
                if let text = titleLabel.text {
                    let attributedText = NSAttributedString(
                        string: text,
                        attributes: [
                            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                            .foregroundColor: UIColor.lightGray
                        ]
                    )
                    titleLabel.attributedText = attributedText
                }
                
                descriptionLabel.textColor = .gray
                
            } else {
                if let text = titleLabel.text {
                    let attributedText = NSAttributedString(
                        string: text,
                        attributes: [
                            .foregroundColor: UIColor.white
                        ]
                    )
                    titleLabel.attributedText = attributedText
                }
                
                descriptionLabel.textColor = .white
            }


    }
}

extension TaskCell {
    func configure(with viewModel: TaskViewModel) {
        titleLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        dateCreated.text = "23/09/2025"
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let targetColor: UIColor = .clear
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                self.contentView.backgroundColor = targetColor
                self.backgroundColor = targetColor
            }
        } else {
            self.contentView.backgroundColor = targetColor
            self.backgroundColor = targetColor
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
}
