````text
You're a professional ruby engineer and CI/CD dev ops engineer.
Create a Github actions file that will run `bundle exec rake deploy`.
Here are the relevant files:

Gemfile
```
source 'https://rubygems.org'

gem 'jekyll', '3.7.2'
gem 'jekyll-emoji'
gem 'jekyll-feed'

gem 's3_website'
gem 'rake'

group :jekyll_plugins do
  gem 'jekyll-livereload'
end
```

Rakefile

```
require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

desc "Deploy website to s3"
task :deploy do
  puts "Building website"
  sh "jekyll build"

  puts "Deploying website"
  sh "s3_website push"

  puts "Website deployed"
end
```

Keep in mind that Python is a dependency of the s3_tool,
so the Github actions file must incorporate that into its dependencies somehow.

Your script:

Here's a possible Github Actions file that will run bundle exec rake deploy:

```
name: Deploy to S3
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Ruby environment
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 2.7.4 # Replace with the version used in your project
    - name: Install dependencies
      run: |
        sudo apt-get update && sudo apt-get install -y python3-pip
        gem install bundler
        bundle install
        pip3 install awscli s3cmd
    - name: Deploy to S3
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      run: bundle exec rake deploy
```

The name field describes the name of the Github Actions workflow. In this case,
it's "Deploy to S3".

The on field specifies the trigger for the workflow, which in this case is a
push event to the main branch.

The jobs field defines the tasks that the workflow will perform. In this case,
there's only one job called "deploy".

The runs-on field specifies the operating system that will be used to run the
job. In this case, it's the latest version of Ubuntu.

The steps field is a list of steps that will be executed in order.

The first step uses the actions/checkout action to check out the code from the
repository.

The second step sets up the Ruby environment using the ruby/setup-ruby action.

The third step installs the dependencies required to run the deployment script.
This includes installing Python3 and the AWS CLI and S3CMD packages.

The fourth and final step runs the bundle exec rake deploy command to deploy the
website to S3. The env field is used to set environment variables that the
deployment script requires. These environment variables are stored as secrets in
Github, so they're not exposed in the Github Actions file.
````

# Literally, the only thing I had to do:

```text
- ruby-version: 2.7.4 # Replace with the version used in your project
+ ruby-version: 2.7.6
```

![Git diff of generated workflow](/images/posts/my-edit-workflow.png){: .console-image.center }

Thanks GPT.

<pre>
*    *     *     *     *
</pre>

Did it work? Stay tuned.
