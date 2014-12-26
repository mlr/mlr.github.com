---
title: Writings
---

{% for post in site.posts %}
  * {{ post.date | date: "%b %d, %Y" }} &ndash; [{{ post.title }}]({{ post.url }}){% endfor %}

