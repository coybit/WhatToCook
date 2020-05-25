//
//  FoodTableCell.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit
import SnapKit
import Nuke

struct FoodTableCellState: Cloneable {
    var image: UIImage?
    var imageUrl: String?
    var title: String
    var imageTask: ImageTask?
}

enum FoodTableCellAction {
    case cellWillAppear(String, String)
    case cellWillDisappear
    case imageDidReceive(UIImage)
    case startGettingImage(ImageTask)
    case errorOccurred(Error)
}

enum FoodTableCellSideEffect {
    case loadImage
    case cancelLoadingImage
}

struct FoodTableCellEnvironment {
}

class FoodTableCell: UITableViewCell {
    static var identifier: String = "FoodTableCell"
    
    private let cardView = UIView()
    private let stackView = UIStackView()
    private let imageViewMeal = UIImageView()
    private let labelMealName = UILabel()
    private var store = Store<FoodTableCellState, FoodTableCellAction, FoodTableCellSideEffect, FoodTableCellEnvironment>(
        state: .init(image: nil, imageUrl: nil, title: "Loading", imageTask: nil),
        reducer: { state, action in
            switch action {
            case .cellWillAppear(let title, let imageUrl):
                return (state: state.set(\.imageUrl, to: imageUrl).set(\.title, to: title),
                        sideEffects: [.loadImage])
            case .cellWillDisappear:
                return (state: state, sideEffects: [.cancelLoadingImage])
            case .imageDidReceive(let image):
                return (state: state.set(\.image, to: image),
                        sideEffects: [])
            case .startGettingImage(let task):
                return (state: state.set(\.imageTask, to: task),
                        sideEffects: [])
            case .errorOccurred(_):
                return (state: state,
                        sideEffects: [])
            }
    },
        sideEffectHandler: { store, sideEffect in
            switch sideEffect {
            case .loadImage:
                guard let urlStr = store.state.imageUrl, let url = URL(string: urlStr) else { return }
                
                let task = ImagePipeline.shared.loadImage(
                    with: url,
                    completion: { result in
                        switch result {
                        case .success(let image):
                            store.dispatch(action: .imageDidReceive(image.image))
                        case .failure(let error):
                            store.dispatch(action: .errorOccurred(error))
                        }
                    }
                )
                
            case .cancelLoadingImage:
                store.state.imageTask?.cancel()
            }
    })
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cardView)
        cardView.addSubview(stackView)
        stackView.addArrangedSubview(imageViewMeal)
        stackView.addArrangedSubview(labelMealName)
        
        cardView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(16)
        }
        
        stackView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        imageViewMeal.snp.makeConstraints { maker in
            maker.height.equalTo(cardView.snp.width)
        }
        
        labelMealName.snp.makeConstraints { maker in
            maker.height.greaterThanOrEqualTo(49)
            maker.width.equalTo(self.snp.width).multipliedBy(0.6)
        }
        
        cardView.backgroundColor = .systemGray6
        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = true
        
        stackView.axis = .vertical
        stackView.alignment = .center
        
        imageViewMeal.contentMode = .scaleAspectFit
        imageViewMeal.clipsToBounds = true
        
        labelMealName.numberOfLines = 0
        labelMealName.textAlignment = .center
        labelMealName.setContentCompressionResistancePriority(.required, for: .vertical)
        labelMealName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        store.on { store in
            DispatchQueue.main.async {
                self.labelMealName.text = store.title
                self.imageViewMeal.image = store.image
                self.setNeedsLayout()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(title: String, image: String) {
        store.dispatch(action: .cellWillAppear(title, image))
    }
    
    override func prepareForReuse() {
        store.dispatch(action: .cellWillDisappear)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
}
