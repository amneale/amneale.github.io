---
layout: post
title: "Automating code review with PHPSpec and Code Climate"
date: 2017-08-01 12:00:00 +0000
categories: phpspec continuous-integration travis-ci code-climate
---
With Continuous Integration (CI) practices becoming more widely adopted, and the number of tools to support them becoming more widespread and available, verifying and analysing check-ins is an important tool in any developers belt.
In this post I'm going to briefly outline how to get started with a basic PHPSpec + CI setup, using tools that are all free for a publicly hosted github repository. The code used in all of the following examples is hosted as a project over on [github](https://github.com/amneale/phpspec-adder).

## PHPSpec Code Coverage
PHPSpec is a great tool that helps when writing clean, testable code. This guide assumes you have prior knowledge, and have written your PHPSpec examples - if not then it's worth [getting started](http://www.phpspec.net/en/stable/manual/getting-started.html) on the official website. If you are using PHPUnit, then you can skip this step and just run your tests making sure you opt to generate coverage.

My [project](https://github.com/amneale/phpspec-adder) is already set up in a very simple state. It has one class `Adder`, containing one method `add` which predictably adds two numbers. Running PHPSpec verifies the behaviour of this method, using the example `it_adds_two_numbers`:
<pre>
vendor/bin/phpspec run -fpretty
      Adder
   9  ✔ adds two numbers
1 specs 
1 examples (1 passed)    
</pre>

This is all well and good, but how do we know what proportion of our code is actually covered by our tests? In more complicated methods, are we sure we aren't just testing the happy path - what if there are edge cases that we are not covering with our tests? Thankfully there is an [extension](https://github.com/leanphp/phpspec-code-coverage) for PHPSpec that will generate coverage for us:
<pre>$ composer require --dev leanphp/phpspec-code-coverage</pre>

To enable the extension and make sure it generates clover formatted output, edit/create the phpspec.yml in the root of your project:
<pre>
extensions:
  LeanPHP\PhpSpec\CodeCoverage\CodeCoverageExtension:
    format: [clover, html]
    output:
      clover: build/logs/clover.xml
      html: build/coverage
</pre>

Now the next time you run your PHPSpec tests coverage reports will automatically be generated. You may want to add `build/` to your `.gitignore` file.

## Travis CI and Code Climate
Once this is done, we need to start analysing our code with every push. You will need to set up a (free) account with both [Travis CI](https://travis-ci.org) and [Code Climate](https://codeclimate.com/).

<div class="well" markdown="span">
**You must get your Test Reporter ID from Code Climate and save it as an environment variable in Travis CI, with the key `CC_TEST_REPORTER_ID`.
You should also make sure that you are using namespaces in your code, otherwise Code Climate may not detect coverage correctly.**
</div>

Thanks to these services being integrated with github, as soon as you have signed up you can enable your github repository (on Travis CI **and** Code Climate). Now before your push there are a couple of final steps.

### Travis configuration
Below is the travis config I'm using on my project - it's worth reading up on how to further [customise your build](https://docs.travis-ci.com/user/customizing-the-build/) but this should work for what we want currently.
<pre>
env:
  global:
    - GIT_COMMITTED_AT=$(if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then git log -1 --pretty=format:%ct; else git log -1 --skip 1 --pretty=format:%ct; fi)

language: php
php:
  - '7.0'

cache:
  directories:
    - $HOME/.composer/cache

install:
  - composer install
  - curl -L https://codeclimate.com/downloads/test-reporter/test-reporter-latest-linux-amd64 > ./cc-test-reporter
  - chmod +x ./cc-test-reporter

before_script:
  - ./cc-test-reporter before-build

script:
  - ./vendor/bin/phpspec run --format=dot

after_script:
  - ./cc-test-reporter after-build --exit-code $TRAVIS_TEST_RESULT
</pre>

### Badges
Lastly you can now add build badges to your repository, ideally in the README.md, to show the latest status of your build. Examples below - but you will need to amend the user and repository names to your own:
<pre>
[![Build Status](https://travis-ci.org/amneale/phpspec-adder.svg?branch=master)](https://travis-ci.org/amneale/phpspec-adder)
[![Test Coverage](https://codeclimate.com/github/amneale/phpspec-adder/badges/coverage.svg)](https://codeclimate.com/github/amneale/phpspec-adder/coverage)
[![Code Climate](https://codeclimate.com/github/amneale/phpspec-adder/badges/gpa.svg)](https://codeclimate.com/github/amneale/phpspec-adder)
[![Issue Count](https://codeclimate.com/github/amneale/phpspec-adder/badges/issue_count.svg)](https://codeclimate.com/github/amneale/phpspec-adder)
</pre>
