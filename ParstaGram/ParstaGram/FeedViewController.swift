//
//  FeedViewController.swift
//  ParstaGram
//
//  Created by Grace Brill on 9/11/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{
    
    var posts = [PFObject]()
    var showCommentBar = false
    let commentBar = MessageInputBar()
    var selectedPost: PFObject!
    

    @IBOutlet var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 1 + number of comments
        let post = posts[section]
        
        //grab comments
        //?? nil coalescing operator
        //set to the thing on the right if nil
        let comments = (post["comments"] as? [PFObject]) ?? []

        return comments.count + 2
    }
    
    //number of sections in the post
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //grab a particular post
        let post = posts[indexPath.section]
        
        //grab comments
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        
        //section 0 for the post
        if indexPath.row == 0
        {
            //grab cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
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
        
        //another cell type - not the add comment
        else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as! String
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        
        //add comment
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //make query using Parse
        let query = PFQuery(className: "Posts")
        //fetch the actual object for author and comments
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    @IBAction func onLogoutButton(_ sender: Any) {
        //do the logout action on Parse
        PFUser.logOut()
        
        //grab storyboard and instantiate
        let main = UIStoryboard(name: "Main", bundle:   nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else {return}
        
        delegate.window?.rootViewController = loginViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification){
        //clear text field
        commentBar.inputTextView.text = nil
        
        showCommentBar = false
        becomeFirstResponder()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //choose a post to apply a comment to
        let post = posts[indexPath.section]
        
        //comments
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            //show comment bar
            showCommentBar = true
            becomeFirstResponder()
            
            //raise keyboard
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showCommentBar
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        //create the comment
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground{ (success, error) in
            if success{
                print("Comment saved")
            }
            
            else{
                print("Error saving comment")
            }
        }
        
        tableView.reloadData()
        
        //clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        
        showCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
        
    }
    
}
