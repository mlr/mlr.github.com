---
title: "Painless Google Doc Image Uploads using Google Apps Scripts"
published: true
---

* TOC
{:toc}

Until now I've mostly avoided the developer ecosystem around Google Apps like
Docs and Sheets. I didn't really have a need for those APIs or any good ideas
about what to do with them. I have played with [Chrome Extensions](/2015/05/24/cities-skylines-gmaps-shortcuts/)
a little bit in the past, but nothing very practical.

It turns out the [Google Apps Scripts](https://developers.google.com/apps-script/)
platform is insanely powerful. You can build add-ons for Google Docs, Sheets,
and Forms including things like custom menus and buttons, custom code triggered
on an [event basis](https://developers.google.com/apps-script/guides/triggers/installable),
or even custom Sheet formula functions.

I hope to provide some insight into Google Apps Scripts based on what I learned while
building a small add-on. I'll go over the steps I took to build the add-on, which is a simple
Google Apps Script that will find and replace image URLs in your Google Doc page with the image itself.

First, I'll talk about the larger concepts needed to tackle it, then
I'll go through the add-on itself, using those concepts along the way.

## Google Apps Scripts

> &nbsp; _"11 Google apps, 1 platform in the cloud"_

<div class="googleapps-image center">
  <img src="{{site.url}}/images/posts/googleapps.png" alt="Google Apps" />
</div>

### What is it?

> Google Apps Script is a JavaScript cloud scripting language that
> provides easy ways to automate tasks across Google products and
> third party services and build web applications.

Google Apps Scripts has a massive API but we'll focus specifically on Docs.

An example of a Google Apps Script looks something like this:

{% highlight javascript %}
// Open a document by ID.
var doc = DocumentApp.openById('DOCUMENT_ID_GOES_HERE');

// Create and open a document.
var doc = DocumentApp.create('Document Name');

// Use the current active document (more on that later).
var doc = DocumentApp.getActiveDocument();
{% endhighlight %}

It's JavaScript, but it exposes a ton of rich objects and interfaces that are
essentially the building blocks of a Google App, it's pretty cool. The
[`DocumentApp`](https://developers.google.com/apps-script/reference/document/document-app)
refers to the Google Docs class that allows you to extend Google Docs behavior and features.

#### Elements of a Document

Below is a Google Doc page, but I've marked it up with some of it's common pieces.
Each piece is an element that you can either create or manipulate using
Google Apps Scripts, which remember is just plain old JavaScript.

<div class="googleapps-image">
  <img src="{{site.url}}/images/posts/googleapps-elements.png" alt="Google Apps Elements" />
</div>

A full list of items including their hierarchy can be found on the
[_Extending Google Docs_](https://developers.google.com/apps-script/guides/docs#structure_of_a_document)
page. Each one of these elements has an extensive reference section that documents all
of the available methods, their return types, and a brief description. For
example,
[here](https://developers.google.com/apps-script/reference/document/paragraph)
is the reference section for `Paragraph`.

I've really got to hand it to the Google Apps team for their documentation, it's
really well structured, so much so that the URLs are quite navigable if you have
an idea what you're looking for. I love me some guessable URLs.

### How to Run Apps Scripts

So you know a Google Doc is made up of several elements in a hierarchy. Those
elements have their own methods that can be used to manipulate (or for some, to
create) that element.

The next thing you probably want to know is _how_ to use those methods. To do
so, you can go to `Tools > Script Editor...` in the Google Docs toolbar.
From there you'll be presented with a code editor that will allow you to type
in some code and run it. The code will be [bound](https://developers.google.com/apps-script/guides/bound)
to the document you're working in. This is important because it will allow us to
reference the document without an ID, using the third variation from earlier:

{% highlight javascript %}
// Use the current active document
var doc = DocumentApp.getActiveDocument();
{% endhighlight %}

#### Adding Text to the Page

With the script editor open, let's do some simple editing of the document.

{% highlight javascript %}
function myFunction() {
  // Get a reference to the current document
  var doc = DocumentApp.getActiveDocument();

  // Get the active document's Body element
  var body = doc.getBody();

  // Add a paragraph to the end of the body
  body.appendParagraph("Hello world!")
}
{% endhighlight %}

Run the script by clicking the "Run" button or type ⌘ + R (you may have to give permission) then switch back to the
Google Doc and you should see the text has been added!

[![Google Apps Scripts: Logs]({{site.url}}/images/posts/googleapps-helloworld.gif)]({{site.url}}/images/posts/googleapps-helloworld.gif)

#### Using the Logger

It's really helpful to know how to print to and read from the log. To do so, you
can use the `Logger` object. Check out the example below:

{% highlight javascript %}
myFunction() {
  Logger.log("Hello world!");
}
{% endhighlight %}

Run the script using the "Run" button in the toolbar or type ⌘ + R. Then, to
view the logs go to `View > Logs` or type ⌘ + Enter.

[![Google Apps Scripts: Logs]({{site.url}}/images/posts/googleapps-scripteditor.gif)]({{site.url}}/images/posts/googleapps-scripteditor.gif)

This will become really useful when we're writing the script because we can
ensure method calls are returning the things we expect. Plus we can use the log
output to figure out which type of element we're dealing with, which we can then
use to find the correct documentation.

Good old [puts debugging](https://tenderlovemaking.com/2016/02/05/i-am-a-puts-debuggerer.html)!

### Events and Triggers

It's all well and good to be able to run code manually with the run button, but
to make this actually useful, we need to know how to respond to actions that
occur, i.e. someone editing the document.  We need some way to activate our
code when we've pasted an image URL.

Enter Triggers.

> Triggers let Apps Script run a function automatically when a certain event, like opening a document, occurs.

Google Apps supports [simple triggers](https://developers.google.com/apps-script/guides/triggers/) like `onChange` and `onOpen`,
so my first thought was _"oh perfect I can just use an onChange trigger!"_ Unfortunately that trigger is only available for Sheets.
It runs when a column or row is added, removed or updated.

Since that's not an option I kept digging and found that Google Apps also supports
[time driven triggers](https://developers.google.com/apps-script/guides/triggers/installable#time-driven_triggers),
which can execute a user-defined function at a given interval. The quickest
interval allowed is once per minute, but that'll do.

#### Creating a Trigger

To setup a time-based trigger it's advised you do so in the `onOpen` function.

{% highlight javascript %}
function myFunction() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();
  body.appendParagraph("Hello world!")
}

function onOpen() {
  ScriptApp.newTrigger("myFunction")
    .timeBased()
    .everyMinutes(1)
    .create();
}
{% endhighlight %}

Save the code and run the `onOpen` function. You'll probably have to select
the function from the dropdown menu to the right of the run button since
there are now two functions defined in your file.

After running the function, switch back to your document. Wait and watch for
a couple minutes while "Hello world" is added to the document over and over again.

#### Cleaning up Triggers

If you run the `onOpen` function multiple times, you'll find that the trigger
has been created again. You can see this by clicking on the "current project triggers"
button, directly left of the "Run" button.

[![google apps scripts: triggers]({{site.url}}/images/posts/googleapps-triggers.png)]({{site.url}}/images/posts/googleapps-triggers.png)

If you don't delete triggers that were there before, your project will be filled
with duplicates which will cause your code to stop running and Google will let
kindly let you know.

[![google apps scripts: trigger error]({{site.url}}/images/posts/googleapps-triggererror.png)]({{site.url}}/images/posts/googleapps-triggererror.png)

You can run this function to clean up your triggers.

{% highlight javascript %}
// Deletes all triggers in the current project.
// https://developers.google.com/apps-script/reference/script/script-app#deletetriggertrigger
function deleteAllTriggers() {
  var triggers = ScriptApp.getProjectTriggers();
  for (var i = 0; i < triggers.length; i++) {
    ScriptApp.deleteTrigger(triggers[i]);
  }
}
{% endhighlight %}

### More on Editing

Having a handle on the document and having the timer trigger in place, we essentially
have an event loop we can use to continually modify the document. To build the add-on
that automatically detects and replaces image URLs we'll need a couple more pieces.

#### Finding Text with Regex

The [`Body`](https://developers.google.com/apps-script/reference/document/body)
class has a method called [`findText`](https://developers.google.com/apps-script/reference/document/body#findtextsearchpattern)
that we'll need to find a URL and replace it with an image.

>findText(searchPattern)
><br>
><br>
>Searches the contents of the element for the specified text pattern using regular expressions.
>The provided regular expression pattern is independently matched against each text block contained in the current element.

<cite>
[https://developers.google.com/apps-script/reference/document/body#findText(String)](https://developers.google.com/apps-script/reference/document/body#findText(String))
</cite>

{% highlight javascript %}
function logHelloWorldText() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();

  // We'll just assume you still have the
  // "Hello world" in the document from earlier.
  // body.appendParagraph("Hello world!")

  selection = body.findText("^Hello world!$")

  if(selection) {
    var element = selection.getElement();
    Logger.log("Element: " + element)
    Logger.log("Type: " + element.getType())
    Logger.log("Text: " + element.getText())
  }
}

function onOpen() {
  ScriptApp.newTrigger("logHelloWorldText")
    .timeBased()
    .everyMinutes(1)
    .create();
}
{% endhighlight %}

```
[17-02-02 15:21:49:497 PST] Element: Text
[17-02-02 15:21:49:498 PST] Type: TEXT
[17-02-02 15:21:49:498 PST] Text: Hello world!
```

From the logs we can see we successfully found our _Hello world!_ text in the
document. From there we can use methods on that Text element like `getText()` to
get or `setBold(true)` to make the text bold (go ahead, try it!).

#### Inserting an Image from a URL

Google docs has this functionality built in, so we're basically replicating the
"Insert > Image > From URL..." functionality here. the `UrlFetchApp` provides a
wrapper around a method called `fetch` that lets us get content at the specified URL.

{% highlight javascript %}
function insertUrlImage() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();
  var url = "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png";
  var fetch_img = UrlFetchApp.fetch(url);
  var imageblob = fetch_img.getBlob();
  body.appendImage(imageblob);
}
{% endhighlight %}

Run that function and you should see the image appear shortly.

Going through line by line, we're familiar with `doc` and `body` already. `url`
is of course the URL that points to the image we want to insert.

The `fetch_img` variable is using the `UrlFetchApp` class and the `fetch` method just mentioned.
This returns an [`HTTPResponse`](https://developers.google.com/apps-script/reference/url-fetch/http-response)
so `fetch_img` will contain an instance of that Class. The [HTTPResponse
reference](https://developers.google.com/apps-script/reference/url-fetch/http-response)
docs list all of the methods available.

One method is the `getBlob` method that will give us the content from the URL as a
[`Blob`](https://developers.google.com/apps-script/reference/base/blob).
Finally, the `appendImage` method on the body instance accepts a `BlobSource`
which conveniently our imageblob variable (the Blob) is one such source.

Here it is in action:

[![google apps scripts: insert image]({{site.url}}/images/posts/googleapps-insertimg.gif)]({{site.url}}/images/posts/googleapps-insertimg.gif)

----

## Putting it All Together

To recap, we've got several pieces working independently. We know how to find
and change text in a document, and we can insert images from a URL. In addition,
we have a timed event trigger set up so our code can execute once per minute.

Now that we have an idea of each piece we'll need, let's make them all work together.

### Finding Image URLs

First, let's get the timed event trigger going and try to find a URL.

{% highlight javascript %}
function insertImages() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();

  var selection = body.findText("https?://")
  var element = selection.getElement();
  var url = element.getText();

  Logger.log(url);
}

function onOpen() {
  // Delete previous triggers
  var allTriggers = ScriptApp.getProjectTriggers();
  for (var i = 0; i < allTriggers.length; i++) {
    ScriptApp.deleteTrigger(allTriggers[i]);
  }

  // Run once immediately and then once per minute.
  insertImages();
  ScriptApp.newTrigger("insertImages")
  .timeBased()
  .everyMinutes(1)
  .create();
}
{% endhighlight %}

[![google apps scripts: logurl]({{site.url}}/images/posts/googleapps-logurl.gif)]({{site.url}}/images/posts/googleapps-logurl.gif)

That's great, but it only finds the first URL on the page. To get all URLs on
the page we can use plain old JavaScript. The `insertImages` method becomes:

{% highlight javascript %}
function insertImages() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();

  var selection;
  var lastSelection = null;

  while(selection = body.findText("https?://", lastSelection)) {
    lastSelection = selection;
    var element = selection.getElement();
    if(element) {
      var url = element.getText();
      Logger.log(url);
    }
  }
}
{% endhighlight %}

We use a `while` loop to find all occurrences of text that looks like a URL. We
track the `lastSelection` and pass it on each successive call so that Google
Docs doesn't have to search from the top of the document every time.

{% highlight bash %}
[17-02-02 17:52:15:503 PST] https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png
[17-02-02 17:52:15:505 PST] https://upload.wikimedia.org/wikipedia/commons/0/05/Twitter-logo-black.png
[17-02-02 17:52:15:508 PST] https://upload.wikimedia.org/wikipedia/en/a/ae/Google_Docs,_Sheets,_and_Slides_Icon.png
{% endhighlight %}

Perfect. Getting closer. Now let's just drop in the images.

### Transforming URLs Into Images

We can insert the images using the same URL fetching technique from earlier, but
this time we'll be more careful by checking the content type of the blob before
we attempt to use it as an image. The `insertImages` method becomes:

{% highlight javascript %}
function insertImages() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();

  var selection;
  var lastSelection = null;

  while(selection = body.findText("https?://", lastSelection)) {
    lastSelection = selection;
    var element = selection.getElement();
    if(element) {
      var url = element.getText();

      // Retrieve the image from the web.
      var fetchimg = UrlFetchApp.fetch(url);
      var imageblob = fetchimg.getBlob();

      if(imageblob && imageblob.getContentType().indexOf("image") != -1) {
        element.getParent().appendInlineImage(imageblob);

        // Remove the URL text element
        element.removeFromParent();
      }
    }
  }
}
{% endhighlight %}

After the image is appended, we remove the Text element containing the URL from
it's parent (the Body in this case). Finally, we've got the basic add-on
behavior we were looking for:

[![google apps scripts: transform images]({{site.url}}/images/posts/googleapps-transformimgs.gif)]({{site.url}}/images/posts/googleapps-transformimgs.gif)

### Resizing the Appended Images

A keen eye will notice the `resizeProportionally` function call after the image
is appended. If you provide a URL to a very large resolution image, the image
will hang off the document.

Instead, we can resize the image after it's appended, so it starts off at a
better default. Below is a function we can use to resize an image so the
dimensions stay proportional.

{% highlight javascript %}
// Resize the image proportionally down to a max width/height
function resizeProportionally(image, maxWidth, maxHeight) {
  var maxWidth = maxWidth || 600;   // default to 600 max width
  var maxHeight = maxHeight || 600; // default to 600 max height

  var width = image.getWidth();
  var height = image.getHeight();

  var widthRatio = maxWidth / width;
  var heightRatio = maxHeight / height;
  var ratio = Math.min(widthRatio, heightRatio);

  var newWidth  = width  * ratio;
  var newHeight = height * ratio;

  if(newWidth < width || newHeight < height) {
    image.setWidth(newWidth);
    image.setHeight(newHeight);
  }
}
{% endhighlight %}

With that in place, `insertImages` becomes:

{% highlight javascript %}
function insertImages() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();

  var selection;
  var lastSelection = null;

  while(selection = body.findText("https?://", lastSelection)) {
    lastSelection = selection;
    var element = selection.getElement();
    if(element) {
      var url = element.getText();

      // Retrieve the image from the web.
      var fetchimg = UrlFetchApp.fetch(url);
      var imageblob = fetchimg.getBlob();

      if(imageblob && imageblob.getContentType().indexOf("image") != -1) {
        var image = element.getParent().appendInlineImage(imageblob);
        resizeProportionally(image);

        // Remove the URL text element
        element.removeFromParent();
      }
    }
  }
}
{% endhighlight %}

### Supporting Droplr Short URLs

I use [Droplr](http://droplr.com) for screen captures when I need to
quickly share with someone. Once you've captured a screenshot, Droplr
automatically copies its short URL to your clipboard so you can paste it
in an email, a Google Doc, or wherever.

It makes for a nice workflow when you can simply snag a screenshot and paste its
short URL right into a Google Doc and have the image insert automatically.

To support this, a small change is required so the Blob data fetched is
the correct type. Droplr will provide the raw downloadable image if you
append a `+` to the end of the short URL.

{% highlight javascript linenos=table %}
function insertImages() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();

  var selection;
  var lastSelection = null;

  while(selection = body.findText("https?://", lastSelection)) {
    lastSelection = selection;
    var element = selection.getElement();
    if(element) {
      var url = element.getText();

      // Droplr provides raw images if the URL is appended with +
      if(url.indexOf("d.pr/i/") != -1 && !url.match(/\+$/)) {
        url = url + "+";
      }

      // Retrieve the image from the web.
      var fetchimg = UrlFetchApp.fetch(url);
      var imageblob = fetchimg.getBlob();

      if(imageblob && imageblob.getContentType().indexOf("image") != -1) {
        var image = element.getParent().appendInlineImage(imageblob);
        resizeProportionally(image);

        // Remove the URL text element
        element.removeFromParent();
      }
    }
  }
}
{% endhighlight %}

Lines 15-17 show the relevant changes.

    

### Limiting Image Fetches

If you have a really large Google Doc or happen to paste a large number of URLs
into the Document over the course of a minute, it may be useful to limit the
number of fetches that occur each time. During development, I also ran into the
page slowing and becoming unresponsive because of an accidental infinite while loop.

To prevent this from happening, a simple precondition on the while loop can be helpful:

{% highlight javascript %}
var i = 0;
var maxruns = 10;
while(i++ < maxruns && (selection = body.findText("https?://", lastSelection))) {
  ...
}
{% endhighlight %}

----

## Wrapping Up

If you're still with me, that's amazing. For such a small add-on, we went
through a lot to get there. Hopefully walking it through has given you a quick
dive into Google Apps Sheets enough so that you feel comfortable delving into
the documentation and trying out your own add-ons.

If you still want to keep going and improve what we have, you might try adding a
button to the UI that will replace the URLs when clicked. That way you don't
have to wait for the 60 second interval to trigger again. :smile:

### The Whole App Script

Here's the entire thing, all put together:

{% highlight javascript %}
function insertImages() {
  var doc = DocumentApp.getActiveDocument();
  var body = doc.getBody();

  var selection;
  var lastSelection = null;

  var i = 0;
  var maxruns = 10;
  while(i++ < maxruns && (selection = body.findText("https?://", lastSelection))) {
    lastSelection = selection;
    var element = selection.getElement();
    if(element) {
      var url = element.getText();

      // Droplr provides raw images if the URL is appended with +
      if(url.indexOf("d.pr/i/") != -1 && !url.match(/\+$/)) {
        url = url + "+";
      }

      // Retrieve the image from the web.
      var fetchimg = UrlFetchApp.fetch(url);
      var imageblob = fetchimg.getBlob();

      if(imageblob && imageblob.getContentType().indexOf("image") != -1) {
        // Append the image and resize it
        var image = element.getParent().appendInlineImage(imageblob);
        resizeProportionally(image);

        // Remove the URL text element
        element.removeFromParent();
      }
    }
  }
}

// Resize the image proportionally down to a max width/height
function resizeProportionally(image, maxWidth, maxHeight) {
  var maxWidth = maxWidth || 600;   // default to 600 max width
  var maxHeight = maxHeight || 600; // default to 600 max height

  var width = image.getWidth();
  var height = image.getHeight();

  var widthRatio = maxWidth / width;
  var heightRatio = maxHeight / height;
  var ratio = Math.min(widthRatio, heightRatio);

  var newWidth  = width  * ratio;
  var newHeight = height * ratio;

  if(newWidth < width || newHeight < height) {
    image.setWidth(newWidth);
    image.setHeight(newHeight);
  }
}

function onOpen() {
  // Delete previous triggers
  var allTriggers = ScriptApp.getProjectTriggers();
  for (var i = 0; i < allTriggers.length; i++) {
    ScriptApp.deleteTrigger(allTriggers[i]);
  }

  // Run once immediately and then once per minute.
  insertImages();
  ScriptApp.newTrigger("insertImages")
  .timeBased()
  .everyMinutes(1)
  .create();
}
{% endhighlight %}

### Publishing the Add-on

In order to reuse the App Script we've created, rather than just
sticking the script in the script editor every time, we can publish it
as an add-on in the [Chrome Web Store](https://chrome.google.com/webstore/).

At the time of publishing this blog post, I was still waiting for approval.

[![google apps scripts: chrome webstore]({{site.url}}/images/posts/googleapps-webstore.png)]({{site.url}}/images/posts/googleapps-webstore.png)

Hopefully it'll be approved soon.

Make something with Google Apps Scipts? Share it with me [on
Twitter](http://twitter.com/ronniemlr)! I'd love to see it.

Cheers!
