//
//  ViewController.swift
//  GameChangeAssignment
//
//  Created by Mayank Gupta on 20/03/20.
//  Copyright © 2020 Archidev. All rights reserved.
//

import UIKit

struct Issues : Decodable {
    let url: String
    let comments_url: String
    let number: Int
    let title: String
    let state: String
    let comments: Int
    let created_at: String
    let updated_at: String
    let body: String
    let user: User
    let timestamp: Date?
}
struct User: Decodable {
    let login: String
    let avatar_url: String
}

let imageCache = NSCache<AnyObject, AnyObject>()

class IssuesViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet var issuesTable: UITableView!
    
    //MARK: PROPERTIES
    let cellIdentifier = "IssueCell"
    let issueUrl = "https://api.github.com/repos/firebase/firebase-ios-sdk/issues"
    var issueArr: [Issues]? = nil
    var issuesCount = Int()
    
    //MARK: VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        callIssuesApi()
    }
    
    private func setupTable() {
        issuesTable.delegate = self
        issuesTable.dataSource = self
        issuesTable.separatorStyle = .none
        issuesTable.register(UINib(nibName: "IssueCell", bundle: nil), forCellReuseIdentifier: "IssueCell")
        issuesTable.rowHeight = UITableViewAutomaticDimension
    }
    
    func callIssuesApi() {
        guard let url = URL(string: issueUrl) else {return}
        DispatchQueue.global(qos: .userInteractive).async {
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                guard let data = data else{return}
                let dataAsString = String(data: data, encoding:.utf8)
                
                do {
                    let course = try JSONDecoder().decode([Issues].self, from: data)
                    course.forEach{ print($0.comments_url) }
                    self.issueArr = course
                    self.issueArr?.sort(by: {$0.updated_at > $1.updated_at})
                    self.issuesCount = course.count
                    DispatchQueue.main.async {
                        self.issuesTable.reloadData()
                    }
                    
                } catch let jsonErr {
                    print("Json err is",jsonErr)
                }
                }.resume()
        }
    }
    
    private func loadImages(_ imageUrl: String)-> UIImage {
        //MARK: IF IMAGE AVAILABLE IN CACHE
        if let imageFromCache = imageCache.object(forKey: imageUrl as AnyObject) as? UIImage {
            return imageFromCache
        }
        
        do {
            let imgData = try Data.init(contentsOf: URL.init(string: imageUrl)!)
            imageCache.setObject(UIImage(data: imgData)!, forKey: imageUrl as AnyObject)
            return UIImage(data: imgData)!
        } catch  {
            //err
        }
        return UIImage()
    }
    
    private func dateFormatter(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM dd YYYY hh:mm a"
            let string = formatter.string(from: date)
            return string
        }
        return ""
    }
    
    private func showSimpleAlert() {
        let alert = UIAlertController(title: "Comments Not Available", message: "There is no comments available for this issue",preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: UITABLEVIEW DELEGATE AND DATASOURCE METHODS
extension IssuesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return issuesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! IssueCell
        if let issueData = issueArr {
            cell.updatedAt.text = dateFormatter(issueData[indexPath.row].updated_at)
            cell.titleLbl.text = issueData[indexPath.row].title
            cell.detailLbl.text = String(issueData[indexPath.row].body.prefix(140))
            DispatchQueue.global(qos: .background).async {
                let image = self.loadImages(issueData[indexPath.row].user.avatar_url)
                DispatchQueue.main.async {
                    cell.avatarView.image = image
                }
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let issues = issueArr else {return}
        let commentUrl = issues[indexPath.row].comments_url
        let numberOfComments = issues[indexPath.row].comments
        if numberOfComments == 0 {
            showSimpleAlert()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            vc.commentUrl = commentUrl
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}



