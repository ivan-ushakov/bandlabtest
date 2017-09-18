//
//  MainViewController.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 14/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let playerView = PlayerView()
    
    private let viewModel: MainViewModel
    
    private var playerConstraint = [NSLayoutConstraint]()
    
    init(_ viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.load()
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.cells.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SongCell.reuseIdentifier, for: indexPath) as? SongCell else {
            fatalError()
        }
        
        cell.bindViewModel(self.viewModel.cells.value[indexPath.row])
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 385)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 20, 0)
    }
    
    // MARK: Private
    
    private func setupUI() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.backgroundColor = UIColor.lightGray
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(SongCell.self, forCellWithReuseIdentifier: SongCell.reuseIdentifier)
        self.view.addSubview(self.collectionView)
        
        self.playerView.translatesAutoresizingMaskIntoConstraints = false
        self.playerView.backgroundColor = UIColor.white
        self.playerView.button.addTarget(self, action: #selector(stopPlayer), for: .touchUpInside)
        self.view.addSubview(self.playerView)
        
        let views: [String : Any] = ["collectionView": self.collectionView,
                                     "playerView": self.playerView]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[collectionView][playerView]-0-|",
            options: [],
            metrics: nil,
            views: views))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[collectionView]-0-|",
            options: [],
            metrics: nil,
            views: views))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[playerView]-0-|",
            options: [],
            metrics: nil,
            views: views))
        
        self.playerConstraint = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[playerView(==0)]",
            options: [],
            metrics: nil,
            views: views)
        self.view.addConstraints(self.playerConstraint)
    }
    
    private func bindViewModel() {
        self.viewModel.cells.onUpdate = { [weak self] _ in
            self?.collectionView.reloadData()
        }
        
        self.viewModel.onPlayerState = { [weak self] state in
            guard let strong = self else { return }
            if state.playing {
                strong.playerView.titleLabel.text = state.song.name
                strong.playerView.authorLabel.text = state.song.author.name
                strong.playerConstraint[0].constant = 40
            } else {
                strong.playerConstraint[0].constant = 0
            }
        }
    }
    
    @objc private func stopPlayer() {
        self.viewModel.stopPlayer()
    }
}

fileprivate class AuthorView: UIView {
    
    let imageView = UIImageView()
    
    let nameLabel = UILabel()
    
    let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let border = CGFloat(15)
        let imageSize = CGFloat(32)
        self.imageView.frame = CGRect(x: border, y: border, width: imageSize, height: imageSize)
        
        // TODO
        self.imageView.layer.cornerRadius = imageSize / 2
        
        let labelWidth = self.frame.width - self.imageView.frame.maxY
        let labelHeight = floor(imageSize / 2)
        let labelX = self.imageView.frame.maxX + 10
        self.nameLabel.frame = CGRect(x: labelX, y: border, width: labelWidth, height: labelHeight)
        self.timeLabel.frame = CGRect(x: labelX, y: self.nameLabel.frame.maxY, width: labelWidth, height: labelHeight)
    }
    
    private func setupUI() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = UIColor.clear
        addSubview(self.imageView)
        
        self.nameLabel.font = UIFont.systemFont(ofSize: 12)
        self.nameLabel.textColor = UIColor.black
        self.nameLabel.textAlignment = .left
        self.nameLabel.backgroundColor = UIColor.clear
        addSubview(self.nameLabel)
        
        self.timeLabel.font = UIFont.systemFont(ofSize: 12)
        self.timeLabel.textColor = UIColor.lightGray
        self.timeLabel.textAlignment = .left
        self.timeLabel.backgroundColor = UIColor.clear
        addSubview(self.timeLabel)
        
        // TODO
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.shouldRasterize = true
        self.imageView.layer.rasterizationScale = UIScreen.main.scale
    }
}

fileprivate class SongCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SongSell"
    
    private let imageView = UIImageView()
    
    private let titleLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    private let authorView = AuthorView()
    
    private let playButton = UIButton(type: .custom)
    
    private var viewModel: SongCellModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor.white
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.viewModel = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = self.contentView.frame.width
        self.imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        
        self.authorView.frame = CGRect(x: 0, y: self.imageView.frame.maxY, width: width, height: self.contentView.frame.height - width)
        
        let buttonSize = CGFloat(48)
        self.playButton.frame = CGRect(x: 136, y: 134, width: buttonSize, height: buttonSize)
        
        let border = CGFloat(15)
        self.titleLabel.frame = CGRect(x: border, y: 239, width: width - 2 * border, height: 25)
        
        let timeLabelWidth = CGFloat(80)
        self.timeLabel.frame = CGRect(x: width - timeLabelWidth - border, y: 290, width: timeLabelWidth, height: 16)
    }
    
    func bindViewModel(_ viewModel: SongCellModel) {
        self.viewModel = viewModel
        
        self.titleLabel.text = viewModel.name
        
        self.authorView.nameLabel.text = viewModel.authorName
        self.authorView.timeLabel.text = viewModel.created
        
        viewModel.playing.onUpdate = { [weak self] value in
            if value {
                self?.playButton.setImage(UIImage(named: "pause_icon"), for: .normal)
            } else {
                self?.playButton.setImage(UIImage(named: "play_icon"), for: .normal)
            }
        }
        viewModel.playing.fire()
        
        viewModel.time.onUpdate = { [weak self] value in
            self?.timeLabel.text = value
        }
        viewModel.time.fire()
        
        viewModel.loadImage(viewModel.coverURL) { [weak self] (url, data) in
            if url != self?.viewModel?.coverURL { return }
            if let imageData = data, let image = UIImage(data: imageData) {
                DispatchQueue.main.async { self?.imageView.image = image }
            }
        }
        
        viewModel.loadImage(viewModel.authorAvatarURL) { [weak self] (url, data) in
            if url != self?.viewModel?.authorAvatarURL { return }
            if let imageData = data, let image = UIImage(data: imageData) {
                DispatchQueue.main.async { self?.authorView.imageView.image = image }
            }
        }
    }
    
    // MARK: Private
    
    private func setupUI() {
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.imageView)
        
        self.authorView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.authorView)
        
        self.playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        self.contentView.addSubview(self.playButton)
        
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.textAlignment = .left
        self.contentView.addSubview(self.titleLabel)
        
        self.timeLabel.font = UIFont.systemFont(ofSize: 14)
        self.timeLabel.textColor = UIColor.white
        self.timeLabel.textAlignment = .right
        self.contentView.addSubview(self.timeLabel)
    }
    
    @objc private func play() {
        self.viewModel?.play()
    }
}
