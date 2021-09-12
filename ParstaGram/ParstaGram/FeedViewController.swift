//
//  FeedViewController.swift
//  ParstaGram
//
//  Created by Grace Brill on 9/11/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var posts = [PFObject]()
    

    @IBOutlet var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return the posts.count
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //grab cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        //grab a particular post
        let post = posts[indexPath.row]
        
        //grab the user and apply to label
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        //caption label
        cell.captionLabel.text = post["caption"] as! String
        
        //image
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        //set the image using the URL
        cell.photoView.af_setImage(withURL: url)
        
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //make query using Parse
        let query = PFQuery(className: "Posts")
        //fetch the actual object for author
        query.includeKey("author")
        //set up limits
        query.limit = 20
        
        query.findObjectsInBackground{(posts, error) in
            //found content
            if posts != nil{
                //store data
                self.posts = posts!
                
                //reload the data
                self.tableView.reloadData()
            }
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
}
