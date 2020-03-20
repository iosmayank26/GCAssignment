//
//  CommentViewController.swift
//  Json
//
//  Created by Mayank Gupta on 19/03/20.
//  Copyright © 2020 Archidev. All rights reserved.
//

import UIKit

struct Comment: Decodable {
    let url: String
    let created_at: String
    let updated_at: String
    let body: String
    let user: User
}

class CommentViewController: UIViewController {
    
    //MARK: OUTLETS
    @IBOutlet var commentsTable: UITableView!
    
    //MARK: PROPERTIES
    let cellIdentifier = "IssueCell"
    var commentUrl: String?
    var commentArr: [Comment]? = nil
    var commentCount = Int()
    
    //MARK: VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Comments"
        setupTable()
        callCommentApi()
    }
    
    private func setupTable() {
        commentsTable.delegate = self
        commentsTable.dataSource = self
        commentsTable.separatorStyle = .none
        commentsTable.register(UINib(nibName: "IssueCell", bundle: nil), forCellReuseIdentifier: "IssueCell")
        commentsTable.rowHeight = UITableViewAutomaticDimension
    }
    
    private func callCommentApi() {
        guard let commentUrl = commentUrl else {return}
        guard let url = URL(string: commentUrl) else {return}
        DispatchQueue.global(qos: .userInteractive).async {
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                guard let data = data else{return}
                let dataAsString = String(data: data, encoding:.utf8)
                
                do {
                    let course = try JSONDecoder().decode([Comment].self, from: data)
                    print(course)
                    self.commentArr = course
                    self.commentCount = course.count
                    DispatchQueue.main.async {
                        self.commentsTable.reloadData()
                    }
                } catch let jsonErr {
                    print("Json err is",jsonErr)
                }
                }.resume()
        }
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
    
    private func loadImages(_ imageUrl: String)-> UIImage {
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
}

//MARK: UITABLEVIEW DELEGATE AND DATASOURCE METHODS
extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! IssueCell
        if let commentData = commentArr {
            cell.updatedAt.text = dateFormatter(commentData[indexPath.row].updated_at)
            cell.titleLbl.text = commentData[indexPath.row].user.login
            cell.detailLbl.text = commentData[indexPath.row].body
            DispatchQueue.global(qos: .background).async {
                let image = self.loadImages(commentData[indexPath.row].user.avatar_url)
                DispatchQueue.main.async {
                    cell.avatarView.image = image
                }
            }
        }
        return cell
    }
    
}

