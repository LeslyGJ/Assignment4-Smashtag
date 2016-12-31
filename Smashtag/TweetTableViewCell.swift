//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Lesly Garcia.
//  Copyright © 2016 Lesly Garcia. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    var tweet: Tweet?{
        didSet{
            updateUI()
        }
    }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var hashtagColor = UIColor.purpleColor()
    var urlColor = UIColor.blueColor()
    var userMentionsColor = UIColor.orangeColor()
    
    func updateUI(){
        //reset tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        
        //load new information
        if let tweet = self.tweet {
            var text = tweet.text
            for _ in tweet.media {
                text += " 📷"
            }
            
            
            //change attributes and colors
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.changeKeywordsColor(tweet.hashtags, color: hashtagColor)
            attributedText.changeKeywordsColor(tweet.urls, color: urlColor)
            attributedText.changeKeywordsColor(tweet.userMentions, color: userMentionsColor)
            attributedText.changeKeywordsColor(tweet.mediaMentions, color: urlColor) 
            tweetTextLabel?.attributedText = attributedText
            
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            self.tweetProfileImageView?.image = nil            
            if let profileImageURL = tweet.user.profileImageURL {
                dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
                    let imageData = NSData(contentsOfURL: profileImageURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        if profileImageURL == tweet.user.profileImageURL {
                            if imageData != nil {
                                self.tweetProfileImageView?.image = UIImage(data: imageData!)
                            }
                        }
                    }
                }
            }
            
            if tweet.hashtags.count + tweet.urls.count + tweet.userMentions.count + tweet.media.count > 0 {
                accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else {
                accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
}

private extension NSMutableAttributedString {
    func changeKeywordsColor(keywords: [Tweet.IndexedKeyword], color: UIColor) {
        for keyword in keywords {
            addAttribute(NSForegroundColorAttributeName, value: color, range: keyword.nsrange)
        }
    }
}
