Attention
=================

 [![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy) 

Attention allows you to:

*Friends*
* Sort your friends by the number of mutual friends
* Unfollow all your friends

*Groups*
* Unfollow all your groups
* Leave all your groups
* Set the notification level of all your groups

*Pages*
* Unfollow all your pages
* Unlike all your pages

*Messages*
* Archive all your messages

Instructions
---
* Deploy to Heroku using the button above (This app simulates actions via the Facebook mobile site thus requires your Facebook username and password.)
* Start a console
* Create an account with `Account.create name: 'Test User', email: 'test@example.com', password: 'test', time_zone: 'London'`
* Load friends/groups/pages/messages with e.g `account.load_friends`
* Perform bulk unfollows etc with `account.friends.each { |friend| friend.unfollow(account) }` 
* Web front end at `/admin`