---
title: "Hakyll deployment: Github -> CircleCi -> AWS CodeDeploy"
tags: haskell
---


[![CircleCI](https://circleci.com/gh/pkinsky/imminent-axolotl/tree/master.svg?style=svg)](https://circleci.com/gh/pkinsky/imminent-axolotl/tree/master)


Once upon a time, I wanted to start a blog. As a gifted procrastinator with a mild aversion to writing, I decided a good first step would be to build out a deployment pipeline such that I could go from version-controlled markdown files to deployed website.

<!--more-->

This post will take you through how I did so while also functioning as a somewhat self-deprecating monument to the developer equivalent of constantly tweaking fonts and slide change animations instead of actually working on a presentation.

At this point, having still not written more than a few words of actual blog post, I tweaked various bits of CSS, Html, added https support, et cetera. Finally, having no excuse not to actually write an article I decided to start by documenting this process.


```
+----------------+
| Github         |       Infrastructure
+-------|--------+      Overview Diagram
        |
+-------v--------+
| CircleCI       |     +------------------+
+-------|--------+  +--> AWS EC2 Instance |
        |           |  +------------------+
+-------v--------+  |  +------------------+
| AWS CodeDeploy +--|--> AWS EC2 Instance |
+----------------+     +------------------+
```


## Static Content Generation

`/site`

- static content via hakyll - but this project started with a hakyll site (based on (todo link to css setup site)) and it provides a nice clean way to generate a static site.


## Yesod Server

`/lamassu-lifeboat` 

Someday I might want to throw together some dynamic server-side content, so I host the static content generated in the previous step using Yesod, a haskell server framework that provides routing, etc, etc. It also has great integration with Keter, which I use to (descr descr)

## Continuous Deployment

`/.cirleci`

I use CircleCi's Github integration to handle continuous integration and deployment. Every commit pushed to github is built. Every commmit pushed to master is built and deployed. The result of the latest build on master is displayed at the header of this page and on the github README page.

## AWS Service Configuration

`/terraform`

- The AWS resources used to deploy this website are (almost) all configured via terraform, an open source tool that lets you capture AWS service configuration as a series of declarative expressions. I love having a description of my AWS setup in code so I don't have to remember all the setup tasks, commands run, AWS GUI interactions, etc etc.

TODO? better descr?

Main components of the AWS setup are:

- an AWS CodeDeploy application
- used to deploy to a cluster of EC2 boxen
- all connected to a domain I own via route 53

