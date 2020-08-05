//
//  SurveyCardView.swift
//  Longevity
//
//  Created by vivek on 03/08/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

struct SurveyCardData {
    let avatarUrl: String
    let header: String
    let content: String
    let extraContent: String
}

class SurveyCardView: CardView {
    var surveyId: String?
    var avatarUrl: URL?
    var header: String?
    var content: String?
    var extraContent: String?

    private let avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let headerLabel: UILabel = {
        let labelView = UILabel()
        labelView.font = UIFont(name: "Montserrat-Medium", size: 20)
        labelView.textColor = UIColor(red: 90/255, green: 167/255, blue: 167/255, alpha: 1)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        return labelView
    }()

    private let contentLabel: UILabel = {
        let labelView = UILabel()
        labelView.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        labelView.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        return labelView
    }()

    private let extraContentLabel: UILabel = {
        let labelView = UILabel()
        labelView.font = UIFont(name: "Montserrat-Regular", size: 16)
        labelView.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        labelView.translatesAutoresizingMaskIntoConstraints = false
        return labelView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        createLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        createLayout()
    }

    init(surveyId:String?,avatarUrl: URL?, header: String?, content: String?, extraContent: String?) {
        super.init(frame: CGRect())
        self.surveyId = surveyId
        self.avatarUrl = avatarUrl
        self.header = header
        self.content = content
        self.extraContent = extraContent
        createLayout()
    }

    func createLayout() {
        self.addSubview(avatar)
        setAvatarImage(from: avatarUrl)
        avatar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        avatar.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        avatar.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -40).isActive = true
        avatar.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -40).isActive = true

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 3.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        headerLabel.text = header
        contentLabel.text = content
        extraContentLabel.text = extraContent

        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(extraContentLabel)

        self.addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
    }


    func setAvatarImage(from urlAddress: URL?) {
        guard urlAddress != nil else { return }

        func getData(from urlAddress: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            URLSession.shared.dataTask(with: urlAddress, completionHandler: completion).resume()
        }

        print("Download Started")
        getData(from: urlAddress!) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? urlAddress!.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                [weak self] in
                self?.avatar.image = UIImage(data: data)
            }
        }
    }
}
