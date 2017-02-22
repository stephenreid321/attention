Attention
=================

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
* Set the FACEBOOK_USERNAME, FACEBOOK_PASSWORD and FACEBOOK_ACCESS_TOKEN environment variables. This app simulates actions via the Facebook mobile site thus requires your Facebook username and password. The access token must have the user_likes access permission.
* Start a server, visit `/admin` and create an account
* Start a console and do `account = Account.first`
* Load friends/groups/pages/messages with e.g `account.load_friends`
* Perform bulk unfollows etc with `account.friends.each { |friend| friend.unfollow(account) }` 