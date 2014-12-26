---
title: Trying out new features of Ruby 2.2
---

The Ruby core team shipped an awesome new version &ndash;
[Ruby 2.2.0](https://www.ruby-lang.org/en/news/2014/12/25/ruby-2-2-0-released)
&ndash; on Christmas day. What an awesome gift! Notable enhancements include
both incremental garbage and symbol garbage collection.

Both of these together should provide noticeable improvements to memory usage
and will allow the Rails core team to "[shed a lot of weight](http://weblog.rubyonrails.org/2014/8/20/Rails-4-2-beta1/#maintenance-consequences-and-rails-5-0)"
with regards to user input and how strings are handled.

Let's try out a couple of the new features, namely `Enumerable#slice_after` and
`Enumerable#slice_when`

## Install Ruby 2.2.0

I really enjoy [ruby-install](https://github.com/postmodern/ruby-install), so
that's how I installed the new version on my system. If you're not already using
it, I highly recommend it.

{% highlight bash %}
ruby-install -u http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.0.tar.bz2 ruby 2.2
{% endhighlight %}

Once that's done downloading and compiling, I simply use
[chruby](https://github.com/postmodern/chruby) to switch to the new version.

{% highlight bash %}
chruby 2.2
{% endhighlight %}

## Enumerable#slice_after

`#slice_after` is a counterpart to the already existing `#slice_before`

This method lets you split an enumerator with each item being grouped into a new
chunk when the result of the block is true.  So in the example below, you can
see a new chunk is created after each odd number.

{% highlight ruby %}
[0,2,4,1,2,4,5,3,1,4,2].slice_after(&:odd?).to_a
# => [[0, 2, 4, 1], [2, 4, 5], [3], [1], [4, 2]]
{% endhighlight %}

## Enumerable#slice_when

This method allows you to slice the enumerable by comparing adjacent elements.
When the block is true a new chunk is created. Say you have an array of numbers
and you want to list them where subsequent numbers are grouped into ranges,
like "1, 5, 9-12, 15" for example.

{% highlight ruby %}
numbers = [1, 5, 9, 10, 11, 12, 15]
grouped = numbers.slice_when { |i, j| i+1 != j }
p grouped.to_a
# => [[1], [5], [9, 10, 11, 12], [15]]

ranges = grouped.map { |a| a.length < 3 ? a : "#{a.first}-#{a.last}" }
p ranges
# => [[1], [5], "9-12", [15]]

p ranges.join(", ")
# => "1, 5, 9-12, 15"
{% endhighlight %}

Let me know what you like about this release. Go forth and be productive!

## Sources and Info

* [Ruby 2.2 release announcement](https://www.ruby-lang.org/en/news/2014/12/25/ruby-2-2-0-released/)
* Enumerable#slice_after &ndash;
  [documentation](http://ruby-doc.org/core-2.2.0/Enumerable.html#method-i-slice_after),
  [discussion](https://bugs.ruby-lang.org/issues/9071)
* Enumerable#slice_when &ndash;
  [documentation](http://ruby-doc.org/core-2.2.0/Enumerable.html#method-i-slice_when),
  [discussion](https://bugs.ruby-lang.org/issues/9826)

