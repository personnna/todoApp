//
//  UIBottomBar+Extension.swift
//  effectivemobile
//
//  Created by ellkaden on 25.09.2025.
//

import UIKit

class BottomBar: UIView {
    
    private let tasksLabel: UILabel = {
        let label = UILabel()
//        label.text = "7 задач"
        label.textColor = .white
        label.font = .appFont(ofSize: 11, weight: .regular)
        return label
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .yellowButton
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.backgroundGray
//        layer.cornerRadius = 12
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateTaskCount(count: Int) {
        let pluralizedWord = pluralize(count: count)
        tasksLabel.text = "\(count) \(pluralizedWord)"
    }
    
    private func setupLayout() {
        addSubview(tasksLabel)
        addSubview(editButton)
        
        tasksLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(15)
        }
    }
    
    private func pluralize(count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder100 >= 11 && remainder100 <= 19 {
            return "задач" // 11, 12, ..., 19 задач
        }
        
        switch remainder10 {
        case 1:
            return "задача"
        case 2, 3, 4:
            return "задачи"
        default:
            return "задач"
        }
    }
}
