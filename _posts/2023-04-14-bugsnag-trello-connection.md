---
title: Configure Bugsnag to sync with Trello
---

I'm embarrassed how long it takes me to figure out how to do this again after it's been several months or potentially years since needing to do it.

The documentation is not helpful at all.  It's difficult to find the right information when you need it quickly. Everyone using slightly different terms doesn't help either.

Anyway, after frustrating trial and error, I finally managed to figure out the steps needed to sync my Bugsnag issues with Trello.

Here they are:

1. Create or visit your [Trello Power-Ups](https://trello.com/power-ups/admin/) admin page.

    ![Visit Power-ups Page](/images/posts/bugsnag-trello/visit-power-ups.png){: .console-image.center }

2. Click on an existing Power-Up or create a new one if needed, filling in the required fields.

    ![Make a new Trello Power-Up or Integration](/images/posts/bugsnag-trello/create-integration.png){: .console-image.center.smaller }

3. Use the "Token" link to get a new token.

    ![Generate a Token](/images/posts/bugsnag-trello/generate-token.png){: .console-image.center }

4. Authorize the Power-Up.

    ![Allow Access to Trello](/images/posts/bugsnag-trello/allow-access.png){: .console-image.center.smaller }

5. Copy the generated token.

    ![Get the Generated Token](/images/posts/bugsnag-trello/get-generated-token.png){: .console-image.center.smaller }

6. Now back in Bugsnag, in your project settings, configure Trello.

    * Application Key:  Use the API key of your Power-Up.
    * Member Token:  Use the newly generated token.

    ![Configure Bugsnag](/images/posts/bugsnag-trello/configure-bugsnag.png){: .console-image.center.smaller }

Click save and you should be done.

Easy now, but you won't remember this. You are welcome future me.
