---
title: "Cities: Skylines &lt;3 Google Maps"
---

I've been playing some [Cities: Skylines](http://store.steampowered.com/app/255710/)
this month. It brings back memories of the SimCity franchise,
before the [always online fiaso](http://mic.com/articles/29213/), except with
finer control over the city and a thriving [library of
mods](https://steamcommunity.com/workshop/browse/?appid=255710&requiredtags[]=Mod).
Including [this mod](https://steamcommunity.com/sharedfiles/filedetails/?id=416064574)
that has a feature to export your creation to OpenStreetMap data. It's pretty awesome.

![Cities: Skylines]({{site.url}}/images/posts/cities-skylines-map.png)

Anyway, I noticed I quickly developed some muscle memory for the game's keyboard
shortcuts for manipulating the map. I wanted to be able to use the same keyboard
shortcuts for Google maps to zoom the map, rotate, etc.  The only logical thing
to do is make it a Chrome extension!

I don't remember if these are the default shortcuts or not,
but here's what I wanted to do:

  * `w``a``s``d` - pan - *This was not possible! [read why](#wasdfail) below.*
  * `z``x` - zoom in/out
  * `q``e` - rotate left/right
  * `t` - tilt

## Setting up the Chrome extension

This tutorial on [developing google chrome
extensions](http://code.tutsplus.com/tutorials/developing-google-chrome-extensions--net-33076)
is pretty helpful to get a simple Google Chrome extension bootstrapped, running
and ready to start developing.

First I made a manifest file in a new directory.

<figure>
<figcaption>manifest.json</figcaption>
{% highlight json linenos=table %}
{
  "manifest_version": 2,
  "name": "CS: Google Maps",
  "version": "1.0",
  "description": "A Cities: Skylines inspired keymapping for Google maps.",
  "content_scripts": [
    {
      "matches": ["https://www.google.com/maps/*"],
      "js": [
        "content_scripts/jquery.js",
        "content_scripts/mapkeys.js"
      ],
      "run_at": "document_start"
    }
  ]
}
{% endhighlight %}
</figure>

Now navigating to `chrome://extensions` and clicking on the
"Load unpacked Extension..." button allows you to load this new extension.

It turns out, this is a pretty basic manifest as far as Chrome extensions go.
I just define two content scripts to load on any page matching a Google maps
URL. The first script is jQuery. The second is the main logic and behavior of
the extension, which I named mapkeys.js.

I didn't need any background scripts, or any sort of setting pages. I didn't even
define a browser action, so no tool bar button will appear when the extension is loaded.

## Borrowing the map buttons

Since Chrome extensions run in an isolated environment from the extension's
content script and we can't actually fire functions the page defines
itself, we have to piggy-back on the map buttons that are already there.

This turns out to be easier anyway because we don't have to try to decipher the
minified JavaScript or play with the breakpoints to figure out what function we
need to call.

Basically, find the right element, trigger a click and let the existing event
handlers on the page handle the rest. These five lines end up being the bulk of
the extension's behavior:

{% highlight javascript %}
$('button[jsaction="compass.left"]').trigger('click'); // rotate left
{% endhighlight %}

{% highlight javascript %}
$('button[jsaction="compass.right"]').trigger('click'); // rotate left
{% endhighlight %}

{% highlight javascript %}
$('button.widget-tilt-button').trigger('click'); // tilt
{% endhighlight %}

{% highlight javascript %}
$('.widget-zoom-in').trigger('click'); // zoom in
{% endhighlight %}

{% highlight javascript %}
$('.widget-zoom-out').trigger('click'); // zoom out
{% endhighlight %}

Google's CSS class names make it pretty obvious what these do.  Try them in the
console of a Google maps page! You might have noticed, there's nothing above for
panning the map. I'm getting to that, but you can [skip ahead](#wasdfail).

## Listening for key events

Handling [keyboard events with
JavaScript](http://javascript.info/tutorial/keyboard-events) is pretty straight
forward, but theres some other considerations that have to be made for this
extension to feel right. In order to not break the UX of Google's existing
features, I had to do four things:

1. **Ignore keys when searching** - If the user is typing a search query, ignore
   any keyboard events and just return. To actually utilize the keyboard shortcuts
   the user will need to click somewhere on the map or otherwise take focus off
   of the search box.

2. **Ignore keys when panning** - If the user is using the arrow keys to move
   and pan the map, again just ignore any keyboard events and return. The map
   becomes jumpy if you're simultaneously panning and trying to rotate
   the map with a mapped key.

3. **Switch to Earth view** - In order to rotate or tilt the map it must
   be in Earth view. So, switch to Earth view before attempting to zoom or tilt.
   Don't automatically switch to Earth view when zooming because that's
   available on the default map view.

4. **Bind keydown handler to the** `window` **object** -
   When the keydown event is captured, we must stop its propagation
   then and there. This is why you'll see I bound my keydown listener
   directly on the window object. Any lower and I wouldn't be able to prevent
   the page from getting it. The result is the map is turning and
   zooming while the search box is filled with silly text like "qeettqzzxqxxq"
   because Google has their own keydown event that focuses the search field when
   you begin to type. Stopping the propagation prevents that. The user can still
   type in the search field, but they have to focus it themselves.

## Putting it all together

The full mapkeys.js can be seen below. For the full project,
check out the [repository](http://github.com/mlr/gmaps-keyboard-shortcuts).

<figure>
<figcaption>mapkeys.js</figcaption>
{% highlight javascript linenos=table %}
window.addEventListener('keydown', function(event) {
  if($('#searchboxinput').is(':focus')) return true;
  if(currentlyPanningMap(event)) return true;

  pressed = letter(event);
  if(pressed != 'Z' && pressed != 'X') switchToEarthMap();

  event.stopImmediatePropagation();
  applyKeyMapping(pressed);
}, true);

currentlyPanningMap = function(event) {
  chr = event.keyCode;
  return chr >= 37 && chr <= 40;
}

switchToEarthMap = function() {
  if(!$('button[jsaction="compass.left"]').length) {
    $('.widget-minimap-shim-button').trigger('click');
  }
}

letter = function(event) {
  if (event.keyCode >= 65 && event.keyCode <= 90) {
    return String.fromCharCode(event.keyCode);
  }
}

applyKeyMapping = function(letter) {
  switch(letter) {
    case 'Q':
      $('button[jsaction="compass.left"]').trigger('click');
      break;
    case 'E':
      $('button[jsaction="compass.right"]').trigger('click');
      break;
    case 'Z':
      $('.widget-zoom-in').trigger('click');
      break;
    case 'X':
      $('.widget-zoom-out').trigger('click');
      break;
    case 'T':
      $('button.widget-tilt-button').trigger('click');
      break;
  }

  return true;
}
{% endhighlight %}
</figure>

The first 10 lines execute the logic of this extension when a key is pressed,
including each of the four UX considerations I outlined above. The `applyKeyMapping`
function takes the letter pressed and fires a click on the appropriate Google map button.
I'm checking the letter pressed rather than the keycode simply for easier modification later.

That's it! Now I can zoom, rotate and tilt the map with custom keyboard shortcuts!

<a name="wasdfail"></a>

## Why panning was a lost cause

I hinted at the [isolated
environment](https://developer.chrome.com/extensions/content_scripts#execution-environment)
Chrome extensions are executed in.  What it boils down to is that you can only
access the DOM of the page the content script is executed on. Since the page has
buttons available for all the other actions (rotate, zoom, tilt), those were
pretty trivial to implement. There are no buttons for panning unfortunately.

Google already has panning available using the keyboard's arrow keys. Maybe you
could just emulating the arrow buttons being pressed!

{% highlight javascript %}
// added to switch statement
case 'S':
  var e = jQuery.Event('keydown');
  e.keyCode = 40; // down arrow
  console.log(e);
  $(document).trigger(e);
  break;
{% endhighlight %}

Unfortunately, this solution doesn't work.  Neither do the other [various
solutions for keypress emulation](http://stackoverflow.com/questions/10455626/).
I suspect this may be due to the isolated environments as well, but honestly I'm
not entirely certain.

Maybe I could reimplement the behavior of panning! Let's see&hellip; need functions
to load map tiles for your current location, stitch tiles together, redraw the map
canvas&hellip; Yeah. I think I'll just use the arrow keys for panning.
