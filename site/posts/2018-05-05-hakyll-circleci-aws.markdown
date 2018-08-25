---
title: "Hakyll deployment: Github -> CircleCi -> AWS CodeDeploy"
tags: haskell
---

Once upon a time, I wanted to start a blog. As a gifted procrastinator with a mild aversion to writing, I decided a good first step would be to build out a deployment pipeline such that I could go from version-controlled markdown files to deployed website. This post will take you through how I did so while also functioning as a somewhat self-deprecating monument to the developer equivalent of constantly tweaking fonts and slide change animations instead of actually working on a presentation.

## The Server


## CircleCI

Of course I wouldn't want to run a bunch of commands every time I ran an update, so I used CircleCI and AWS CodeDeploy to set up automated deployments triggered by commits to the master branch. 

## AWS

- introduce code deploy, then introduce terraform

## Keter

Of course I wouldn't want to manually handle all the ops tasks of setting up that AWS env via the console, so I used terraform to create a declarative description of the AWS env to which deployments would occur. 

At this point, having still not written more than a few words of actual blog post, I tweaked various bits of CSS, Html, added https support, et cetera. Finally, having no excuse not to actually write an article I decided to start by documenting this process.

<!--more-->

### First, let's take a look at a high-level sketch of this setup.


## NOTES

just created a second ec2 node using same provisioner stuff, now failing with

> The hostname you have provided, ec2-54-191-225-128.us-west-2.compute.amazonaws.com, is not recognized.




## END NOTES

(ASCII diagram with Github -> CircleCI -> AWS CodeDeploy deployment group)


### Deployment Flow

- Github Repo
-- actual code
-- deployment shit
-- haskell project subdir
- Continous Integration/Deployment via CircleCI
-- build step
--- build project and run tests (if any)
--- create static site artifacts
-- deploy step
--- deploy revision to AWS using `aws deploy push (..)`, `aws deploy create-deployment (..)`
- AWS CodeDeploy Deployment Group
-- blah blah blah aws high level summary of _just_ the codedeploy deployment group and, idk, the ELB fronting it
-- end with note: I'm going to go over my TF config later, in a future blog post (maybe after moving to terrafomo)
-- 'just check out the tf file' (which is kinda still a mess, lel)
-- in the meantime, AWS provides tutorials and a wizard for creating a codedeploy deployment group. You should be able to get started by just using the wizard and working with the deployment group it creates for you.


ALSO NOW I'M USING KETER YEET YEET GOT THAT SCP STEEZ

[![CircleCI](https://circleci.com/gh/pkinsky/imminent-axolotl/tree/master.svg?style=svg)](https://circleci.com/gh/pkinsky/imminent-axolotl/tree/master)

