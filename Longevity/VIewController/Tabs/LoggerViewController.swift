//
//  LoggerViewController.swift
//  Longevity
//
//  Created by vivek on 25/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class LoggerViewController: BaseViewController{
    var loggerData: [LogItem]?
    lazy var logDataCollection: UICollectionView = {
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.backgroundColor = UIColor(red: 229.0/255, green: 229.0/255, blue: 234.0/255, alpha: 1)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.delegate = self
        collection.dataSource = self
        collection.alwaysBounceVertical = true
        return collection
    }()

    init() {
        super.init(viewTab: .logger)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logger = Logger()
        self.loggerData = logger.getLoggerData()

        self.view.addSubview(logDataCollection)

        NSLayoutConstraint.activate([
            logDataCollection.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            logDataCollection.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            logDataCollection.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            logDataCollection.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])


        guard let layout = logDataCollection.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        layout.sectionInset = UIEdgeInsets(top: 50.0, left: 0.0, bottom: 10.0, right: 0.0)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 20.0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let logger = Logger()
        self.loggerData = logger.getLoggerData()
        logDataCollection.reloadData()
    }
}

extension LoggerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loggerData?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.getCell(with: LogItemCell.self, at: indexPath) as? LogItemCell else {
            preconditionFailure("Not a proper cell")
        }
        guard let data = loggerData as? [LogItem]  else {
            preconditionFailure("Not a proper cell")
        }
        if data.count == indexPath.item {
            preconditionFailure("Limit exceeded")
        }
        let cellData = data[indexPath.item]
        cell.createLayout(time: cellData.time, info: cellData.info)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.width - 40
        var height = CGFloat(50)

        guard let data = loggerData as? [LogItem] else{
            return CGSize(width: width, height: height)
        }
        guard let itemData = data[indexPath.item] as? LogItem else{
            return CGSize(width: width, height: height)
        }

        height = CGFloat(0)
        height += itemData.info.height(withConstrainedWidth: width, font: UIFont.systemFont(ofSize: 20))
        height += 20
        return CGSize(width: width, height: height)
        //.height(withConstrainedWidth: width - 40.0, font: answerCell.questionLabel.font)

    }
}

class LogItemCell: UICollectionViewCell {
    lazy var cardView: CardView = {
        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        return card
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func createLayout(time:String, info:String) {
        self.addSubview(cardView)
        self.addSubview(timeLabel)
        self.addSubview(infoLabel)
        let timeLabelWidth = self.bounds.width * 0.3 // 30 percent of width
        timeLabel.text = time
        infoLabel.text = info

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardView.topAnchor.constraint(equalTo: self.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            cardView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            timeLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            timeLabel.topAnchor.constraint(equalTo: cardView.topAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: timeLabelWidth),

            infoLabel.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
            infoLabel.topAnchor.constraint(equalTo: cardView.topAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor)
        ])


    }
}
