---
title: Slack bot for API Documentation
---

The number of Slack bots, Slack plug-ins and other integrations available
recently seems to have skyrocketed. There are plug-ins to help facilitate [live
blogging](https://twitter.com/moriogawa/status/629485213849157632/), bots that
can [book rooms for your team](https://www.roomino.com/) (hopefully better than
your company's travel department), there's even a Slack bot that will
[listen to all of your frustrations](http://christinac.github.io/ellie-slack/).

At work we switched to Slack recently and there are many things I've been
wanting to try. One being to create a bot that will give API documentation
and example responses.

In order to do this we'll take a simple JSON schema, parse it a bit,
then provide a sample response based on the schema. To handle this I'm
leaning heavily on both [Prmd](http://github.com/interagent/prmd),
a tool for managing JSON schemas and generating documentation from them and
for the Slack integration, the excellent
[slack-ruby-bot](http://github.com/dblock/slack-ruby-bot).

## Creating a JSON Schema

I just recently started diving into JSON schema, so I'm still fairly new myself.
I found the online book *[Understanding JSON
Schema](http://spacetelescope.github.io/understanding-json-schema/)* to be a
great resource. For the purposes of this blog post I'm going to use a generic "person"
schema. This person object will have a first name, last name, and an email address.

We'll use Prmd to combine a `meta.yml` and a `person.yml` file into our
`schema.json` file.

<figure>
<figcaption>meta.yml</figcaption>
{% highlight yaml %}
id: "person-api"
description: "Person Example API"
title: "Person Example API"
links:
  - href: "https://api.example.com"
    rel: "self"
definitions:
  identity:
    "$ref": "#/definitions/id"
  id:
    description: "Unique identifier of a resource."
    example: "1dc3567e-acd4-4819-afd5-21d0ef677dcd"
    readOnly: true
    format: "uuid"
    type: "string"
{% endhighlight %}
</figure>

<figure>
<figcaption>person.yml</figcaption>
{% highlight yaml %}
id: "person"
title: "Person"
properties:
  id:
    "$ref": "#/definitions/id"
  first_name:
    description: "The person's first name."
    example: "Jean-Luc"
    type: "string"
  last_name:
    description: "The person's last name."
    example: "Picard"
    type: "string"
  email_address:
    description: "The person's email address."
    example: "locutus@borg.hive"
    format: "email"
    type: "string"
definitions:
  person:
    description: "A single person"
    properties:
      id:
        "$ref": "#/id"
      first_name:
        "$ref": "#/first_name"
      last_name:
        "$ref": "#/last_name"
      email_address:
        "$ref": "#/email_address"
    type: "object"
links:
  - title: "Person details"
    description: "Get the details of a person"
    method: GET
    href: "/person/{#/definitions/identity}"
    targetSchema:
      "$ref": "#/person"
{% endhighlight %}
</figure>

Combining these into a single schema file is easy:

{% highlight bash %}
prmd combine --meta meta.yml person.yml > schema.json
{% endhighlight %}

This produces:

<figure>
<figcaption>schema.json</figcaption>
{% highlight javascript %}
{
  "$schema": "http://interagent.github.io/interagent-hyper-schema",
  "type": [
    "object"
  ],
  "definitions": {
    "identity": {
      "$ref": "#/definitions/id"
    },
    "id": {
      "description": "Unique identifier of a resource.",
      "example": "1dc3567e-acd4-4819-afd5-21d0ef677dcd",
      "readOnly": true,
      "format": "uuid",
      "type": [
        "string"
      ]
    },
    "person": {
      "title": "Person",
      "properties": {
        "id": {
          "$ref": "#/definitions/id"
        },
        "first_name": {
          "description": "The person's first name.",
          "example": "Jean-Luc",
          "type": [
            "string"
          ]
        },
        "last_name": {
          "description": "The person's last name.",
          "example": "Picard",
          "type": [
            "string"
          ]
        },
        "email_address": {
          "description": "The person's email address.",
          "example": "locutus@borg.hive",
          "format": "email",
          "type": [
            "string"
          ]
        }
      },
      "definitions": {
        "person": {
          "description": "A single person",
          "properties": {
            "id": {
              "$ref": "#/definitions/id"
            },
            "first_name": {
              "$ref": "#/definitions/first_name"
            },
            "last_name": {
              "$ref": "#/definitions/last_name"
            },
            "email_address": {
              "$ref": "#/definitions/email_address"
            }
          },
          "type": [
            "object"
          ]
        }
      },
      "links": [
        {
          "title": "Person details",
          "description": "Get the details of a person",
          "method": "GET",
          "href": "/person/{#/definitions/identity}",
          "targetSchema": {
            "$ref": "#/definitions/person"
          }
        }
      ]
    }
  },
  "properties": {
    "person": {
      "$ref": "#/definitions/person"
    }
  },
  "id": "person-api",
  "description": "Person Example API",
  "title": "Person Example API",
  "links": [
    {
      "href": "https://api.example.com",
      "rel": "self"
    }
  ]
}
{% endhighlight %}
</figure>

## Creating a basic Slack bot

We will need the following files:

{% highlight bash %}
docutron/
  response.rb
docutron.rb
Gemfile
schema.json # the generated output from above
{% endhighlight %}

### Gemfile

{% highlight ruby %}
source 'http://rubygems.org'

gem 'slack-ruby-bot'
gem 'prmd'
{% endhighlight %}

## docutron.rb

This will be the main entry point into the bot when a webhook payload is received.

{% highlight ruby linenos=table %}
require 'slack-ruby-bot'
require_relative 'docutron/response'

module Docutron
  class App < SlackRubyBot::App
  end

  class SlackBot < SlackRubyBot::Commands::Base
    DOC_REQUEST = /^(?<request_method>\w*) (?<resource>\w*)$/

    match DOC_REQUEST do |client, data, match|
      method, resource = match[:request_method], match[:resource]
      response = Docutron::Response.new(method, resource)
      response.send(client, data.channel)
    end
  end
end

Docutron::App.instance.run
{% endhighlight %}

We match against the incoming message using the SlackRubyBot's `.match` method.
We're looking for a message in the form of `[request method] [resource name]`,
For instance:

> GET person

When a message is received, we create a new `Docutron::Response` instance and pass
it the request method and the resource. We then call `#send` to respond in the
Slack channel the message was sent from.

## docutron/response.rb

This is where we'll do the bulk of the work of loading and parsing the schema,
choosing the correct schema link for the requested resource, then returning the
appropriate response.

{% highlight ruby linenos=table %}
require 'prmd'

module Docutron
  class Response
    UnknownResponse = "Sorry, I don't know about that resource.".freeze

    def initialize(method, resource)
      @method   = method.upcase
      @resource = resource
      @schemata = "#/definitions/#{@resource}"
      @schema   = Prmd::Schema.new(JSON.parse(File.read('schema.json')))
    end

    def link
      @schema['definitions'][@resource]['links'].detect do |link|
        link['method'] == @method
      end or raise UnknownResponse
    end

    def json_example
      if link['rel'] == 'empty'
      elsif link.has_key?('targetSchema')
        JSON.pretty_generate(@schema.schema_example(link['targetSchema']))
      elsif link['rel'] == 'instances'
        JSON.pretty_generate([@schema.schemata_example(@schemata)])
      else
        JSON.pretty_generate(@schema.schemata_example(@schemata))
      end
    end

    def message
      "```#{json_example}```"
    end

    def send(client, channel)
      client.message text: message, channel: channel
    end
  end
end
{% endhighlight %}

The initializer of the `Docutron::Response` class sets up some instance variables
and creates a new `Prmd::Schema` instance using the schema.json data.

The `#link` method finds the schema's link definition for the resource and the request
method of the incoming Slack message. Our basic person schema defines one link:

{% highlight json %}
{
  "title": "Person details",
  "description": "Get the details of a person",
  "method": "GET",
  "href": "/person/{#/definitions/identity}",
  "targetSchema": {
    "$ref": "#/definitions/person"
  }
}
{% endhighlight %}

The `#json_example` method uses the link to generate a JSON example either using
the `targetSchema` of the link if it exists, or by using a default json
reference for the resource, in this case `#/definitions/person`. If the link has
a rel of "instances", it wraps the response in an array. This
method is adapted from [Prmd's link.md.erb
template](https://github.com/interagent/prmd/blob/master/lib/prmd/templates/schemata/link.md.erb).

The important bit here is the `@schema.schemata_example(@schemata)` which
returns a JSON object based on the properties defined for a given "schemata" and
the example values defined in the schema. For person it looks like this:

{% highlight json %}
{
  "id": "1dc3567e-acd4-4819-afd5-21d0ef677dcd",
  "first_name": "Jean-Luc",
  "last_name": "Picard",
  "email_address": "locutus@borg.hive"
}
{% endhighlight %}

Finally, the `#message` method wraps the JSON example in triple back ticks so
that Slack will format the message as preformatted text. The `#send` method as
you recall is what our Slack bot actually calls to send the message.

## Configure Slack

The final step to run this basic Slack bot is to configure your team's
integrations. First create a new bot by going to the [Add Bot](https://slack.com/services/new/bot)
page. Create a new bot and obtain the bot's API token. You'll need this to start the bot.
Next, from the [Add Outgoing Webhooks](https://slack.com/services/new/outgoing-webhook)
page create a new outgoing webhook and choose a specific
channel for your bot to monitor.

To run the bot use the command:

{% highlight text %}
SLACK_API_TOKEN=bot_api_token_here ruby docutron.rb
{% endhighlight %}

![Slackbot: Docutron]({{site.url}}/images/posts/slackbot-docutron.gif){: .console-image }

## Just the beginning

For the documentation to be truly useful, you'll of course want more
information. Maybe some details about each property, for example.
Prmd has templates to handle generating that which could be
adapted for docutron, but I leave that as an exercise for the reader.

Happy Slacking!

## Resources

* [Docutron source code](http://github.com/mlr/docutron)
* [Understanding JSON Schema](http://spacetelescope.github.io/understanding-json-schema/)
* [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot)
* [Prmd](https://github.com/interagent/prmd)
