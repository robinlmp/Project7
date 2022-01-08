//
//  ViewController.swift
//  Project7
//
//  Created by Robin Phillips on 08/01/2022.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filtered = [Petition]()
    var isFiltered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "US Petitions"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showFilter))
        
        //         let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        let urlString: String

        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }

        showError()
        
        
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Copyright credit", message: "The data for this app comes from the 'We The People' API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showFilter() {
        
        let ac = UIAlertController(title: "Filter petitions", message: "Enter text", preferredStyle: .alert)
        
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Filter", style: .default) { [weak self, weak ac] action in
            guard let text = ac?.textFields?[0].text else { return }
            self?.filterPetitions(text)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [self] _ in
            isFiltered = false
            tableView.reloadData()
        } )

        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func filterPetitions(_ filter: String) {
        filtered = petitions.filter { $0.title.contains(filter) || $0.body.contains(filter) }
        isFiltered = true
        tableView.reloadData()
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltered {
            return filtered.count
        } else {
            return petitions.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petition: Petition
        
        if isFiltered {
            petition = filtered[indexPath.row]
        } else {
            petition = petitions[indexPath.row]
        }
        
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        
        if isFiltered {
            vc.detailItem = filtered[indexPath.row]
        } else {
            vc.detailItem = petitions[indexPath.row]
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

