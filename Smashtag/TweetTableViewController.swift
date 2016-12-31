//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Lesly Garcia.
//  Copyright © 2016 Lesly Garcia. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [[Tweet]]()
    var searchText: String? = "#csumb" {  //initial search tag
        didSet{
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight //load table view rows
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refresh()
    }
    
    
    func refresh(){
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            RecentSearches().add(searchText!)
            if let request = nextRequestToAttempt {
                //fetchtweets is async API therefore must re-dispatch main queue upon return
                request.fetchTweets{ (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections)), withRowAnimation: .None)
                            sender?.endRefreshing()
                            self.title = self.searchText
                        }
                    }
                }
                print("requested")
            }
        }
        sender?.endRefreshing()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var searchTextField: UITextField! {
        didSet{
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField{
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print ("ret tableView \(tweets[section].count)")
        return tweets[section].count
    }
    
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
        static let MentionsIdentifier = "Show Mentions"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> TweetTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        
        cell.tweet = tweets[indexPath.section][indexPath.row]
        
        return cell
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == Storyboard.MentionsIdentifier {
            if let tweetCell = sender as? TweetTableViewCell {
                if tweetCell.tweet!.hashtags.count + tweetCell.tweet!.urls.count + tweetCell.tweet!.userMentions.count + tweetCell.tweet!.media.count == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.MentionsIdentifier {
                if let mtvc = segue.destinationViewController as? MentionsTableViewController {
                    if let tweetCell = sender as? TweetTableViewCell {
                        mtvc.tweet = tweetCell.tweet
                    }
                }
            }
        }
    }
}
