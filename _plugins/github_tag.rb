# A Liquid tag for Jekyll sites that allows outputting repos using Github's API
#
# Author: Ronnie Miller
# Source URL: https://github.com/mlr/jekyll-github-tag
#
# Example usage:
#   {% github mlr %}
#
# Documentation:
#   https://github.com/mlr/jekyll-github-tag/blob/master/README.md
#

require 'json'
require 'digest'
require 'net/http'
require 'uri'
require 'htmlentities'

module Jekyll
  class GithubTag < Liquid::Tag
    @@github_repos_url = "https://api.github.com/users/{username}/repos?type=owner"

    def initialize(tag_name, config, tokens)
      super
      @username = config.split[0]

      @config = Jekyll.configuration({})['github_repos'] || {}
      @config['github_tag'] ||= 'div'
      @config['github_id']  ||= 'repos'
      @config['a_target']   ||= '_blank'
    end

    def render(context)
      <<-EOF

      <#{@config['github_tag']} id="#{@config['github_id']}">
        #{repos.collect{|repo| render_repository(repo)}.join("\n")}
      </#{@config['github_tag']}>
      EOF
    end

    def render_repository(repo)
      <<-EOF
      <div>
        <h4><a href="#{repo.url}" target="#{@config['a_target']}">#{repo.name}</a></h4>
        <p>#{HTMLEntities.new.encode(repo.description)}</p>
      </div>
      EOF
    end

    def repos
      @repos = Array.new

      JSON.load(json).reject! { |repo| repo['fork'] }.each do |repo|
        @repos << GithubRepo.new(repo['name'], repo['html_url'], repo['description'], repo['pushed_at'])
      end

      @repos.sort
    end

    def json
      response     = ""
      uri          = ::URI.parse("https://api.github.com/users/#{@username}/repos?type=owner")
      http         = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == 'https'

      http.start {
        http.request_get(uri.path) do |res|
          response = res.body
        end
      }

      response
    end
  end

  class GithubRepo
    attr_reader :name, :url, :description, :pushed_at

    def initialize(name, url, description, pushed_at)
      @name        = name
      @url         = url
      @description = description
      @pushed_at   = pushed_at
    end

    def <=>(repo)
      repo.pushed_at <=> @pushed_at
    end
  end
end

Liquid::Template.register_tag('github', Jekyll::GithubTag)
