//
//  CustomModalVC.swift
//

import UIKit
import SwiftyJSON

class CustomModalVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    private var filtered = [JSON]()
    
    var adapter: JSONListAdapter?
    var itemTitleKey:[JSONSubscriptType] = ["#title"]
    var itemDescKey:[JSONSubscriptType]? = nil
    var urlImageKey:[JSONSubscriptType]? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        initTitle()
        initSearchTextField()
        initTableView()
        
        filtered = adapter?.items ?? []
        tableView.reloadData()
    }

    private func initTitle() {
        titleLabel.text = title
        self.view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(15)
            make.centerX.equalToSuperview()
        }
    }
    
    private func initSearchTextField() {
        self.view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(60)
            
        }
    }
    
    private func initTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CustomModalTableViewCell.self, forCellReuseIdentifier: CustomModalTableViewCell.identifier)
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension CustomModalVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomModalTableViewCell.identifier, for: indexPath) as! CustomModalTableViewCell
        cell.titleLabel.text = filtered[indexPath.row][itemTitleKey].rawString() ?? "-"
        if let itemDescKey = itemDescKey {
            cell.descLabel.text = filtered[indexPath.row][itemDescKey].rawString() ?? " "
        }
        else{
            cell.descLabel.text = ""
        }
        
        if let urlImageKey = urlImageKey {
            cell.leftImageView.isHidden = false
            cell.leftImageView.image = UIImage(systemName: "square.fill")
            
            if let imageUrl = URL(string: filtered[indexPath.row][urlImageKey].stringValue) {
                DispatchQueue.global().async {
                    guard let imageData = try? Data(contentsOf: imageUrl) else {
                        return
                    }
                    DispatchQueue.main.async {
                        if let image = UIImage(data: imageData) {
                            cell.leftImageView.image = image
                        }
                    }
                }
            }
            
            
        
        }
        else{
            cell.leftImageView.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.adapter?.selected = filtered[indexPath.row]
        self.adapter?.selectedChanged()
        self.dismiss(animated: true)
    }
}

extension CustomModalVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {
            return
        }
        filtered = []
        let data = adapter?.items ?? []
        if text == "" {
            filtered = data
        } else {
            for item in data {
                if item[itemTitleKey].stringValue.lowercased().contains(text.lowercased()) {
                    filtered.append(item)
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension JSONListAdapter {
    func showModalVC(vc:UIViewController,title: String? = nil, itemTitleKey: [JSONSubscriptType], itemDescKey: [JSONSubscriptType]? = nil, urlImageKey: [JSONSubscriptType]? = nil) {
        let modalVC = CustomModalVC()
        modalVC.adapter = self
        modalVC.itemTitleKey = itemTitleKey
        modalVC.itemDescKey = itemDescKey
        modalVC.urlImageKey = urlImageKey
        modalVC.title = title
        vc.present(modalVC, animated: true)
    }
}

















class CustomModalTableViewCell: UITableViewCell {

    static let identifier = "CustomModalTableViewCell"
    let titleLabel = UILabel()
    let descLabel = UILabel()
    
    let leftImageView: UIImageView  = {
        let leftImageView = UIImageView()
        leftImageView.tintColor = .darkGray
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.image = UIImage(systemName: "square.fill")
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(40)
        }
        
        return leftImageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .darkGray
        
        
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fill
        horizontalStack.alignment = .center
        horizontalStack.spacing = 15
        self.contentView.addSubview(horizontalStack)
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            
        }
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.distribution = .fill
        textStack.alignment = .fill
        textStack.spacing = 3
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(descLabel)
        
  
        horizontalStack.addArrangedSubview(leftImageView)
        horizontalStack.addArrangedSubview(textStack)
        
        
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

