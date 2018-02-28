---
layout: post
title: "Automating acceptance tests with Behat"
date: 2018-02-28 12:00:00 +0000
categories: testing
tags: behat testing BDD TDD
---
[Behat](http://behat.org/) is the official PHP implementation of [Cucumber](https://cucumber.io), an open source tool used to drive Behaviour Driven Development (BDD).
It encourages collaboration between developers, testers and stakeholders, by promoting writing concrete examples of how software should behave.
These documents then become both the specification and the tests for the application.

## The BDD software lifecycle
Starting with **Discovery**, the stakeholder, testers and developers meet to explore what exactly the software should be doing.
This can be a fairly informal, interactive discussion, with the ultimate goal being to develop a set of requirements that all are agreed upon.

Following this comes **Formalisation**, where these requirements are converted into concrete scenarios, which all together become the basis of our new feature file (more on this later).

After this comes the **Automation**, where upon the acceptance tests are written and run repeatedly for the feature files. 
Using both Behat and Unit tests and the [red-green-refactor](http://www.jamesshore.com/Blog/Red-Green-Refactor.html) approach, this should be done by writing an over-arching acceptance test, then incremental unit tests within, until the acceptance test passes.

Finally the code can be put into production, matching the specification agreed upon by the stakeholder, and continuing to test this specification on subsequent code changes.

## The feature file
Behat uses [Gherkin](https://github.com/cucumber/cucumber/wiki/Gherkin) syntax, with keywords such as *Features*, *Scenarios* and *Give/When/Then* to create a plain language that is both human readable, and intepretable for automation.

An example can be seen below, of a scenario where a user should be able to process a refund for a purchased item.

<pre>
Feature: Refund item

Scenario: Jeff returns a faulty microwave
  Given Jeff has bought a microwave for £100
    And he has a receipt
  When he returns the microwave
  Then Jeff should be refunded £100
</pre>

## The context file
To run the automation, we must give Behat context about what to do when it reads a step from the feature file.
This can be an involved process, using regex to parse parameters, and doing some complicated back-end work when necessary.
The important thing is to put the complex logic in these context files, and to keep the feature file slim and readable.
More information about writing your context files can be found in the [official documentation](http://behat.org/en/latest/quick_start.html#defining-steps)

## Additional tools
Behat integrates well with a number of tools, including [Mink](https://github.com/Behat/MinkExtension) which by using drivers can simulate browser interaction.
These vary from headless drivers (Goutte, Zombie) to Selenium, which actually launches a browser window and can interact with JavaScript on your application.

There are also extensions for popular frameworks, including [Symfony](https://github.com/Behat/Symfony2Extension) and [Drupal](https://github.com/jhedstrom/drupalextension).

## Other language alternatices
If PHP is not your language of choice, there are alternatives available including official Cucumber implementations for JavaScript, JVM and Ruby.
There are also a number of implementations for Python, including Behave, Lettuce and Radish.
