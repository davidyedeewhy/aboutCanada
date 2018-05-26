//
//  CanadaFactsViewController.swift
//  AboutCanada
//
//  Created by Dhaval Thakkar on 26/5/18.
//  Copyright © 2018 David Ye. All rights reserved.
//

import UIKit

class CanadaFactsViewController: UITableViewController {
    
    // MARK: varibles
    private var navigationBarTitle: String? {
        didSet {
            navigationItem.title = navigationBarTitle
        }
    }
    private let endpoint = "https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json"
    private var facts: [Fact] = []

    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestFacts(self)
    }

    @objc func requestFacts(_ sender: Any) {
        let networkManager = NetworkManager()
        networkManager.loadFacts(endpoint, success: { canadaFacts in
            DispatchQueue.main.async { [weak self] in
                if let refreshControl = sender as? UIRefreshControl,
                    refreshControl.isRefreshing
                {
                    refreshControl.endRefreshing()
                }
                if let title = canadaFacts["title"] as? String {
                    self?.navigationBarTitle = title
                }
                if let facts = canadaFacts["rows"] as? [[String: String?]] {
                    print(facts)
                }
                self?.facts = (canadaFacts["rows"] as? [[String: String?]])?.map({ row in
                    Fact(title: row["title"] as? String, description: row["description"] as? String, imageHref: row["imageHref"] as? String)
                }) ?? []
                self?.tableView.reloadData()
            }
        }) { (error) in
            DispatchQueue.main.async {
                if let refreshControl = sender as? UIRefreshControl,
                    refreshControl.isRefreshing
                {
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (facts.count > 0).hashValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return facts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "canadaFact", for: indexPath)
        let fact = facts[indexPath.row]
        cell.textLabel?.text = fact.title
        cell.detailTextLabel?.text = fact.description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let fact = facts[indexPath.row]
        if let imageHref = fact.imageHref,
            let url = URL(string: imageHref)
        {
            let networkManager = NetworkManager()
            // TODO: use lazy loading to show image
            networkManager.loadImage(url, success: { (data) in
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        cell.imageView?.image = image
                    }
                }
            }) { (error) in
                
            }
        }
    }

}
