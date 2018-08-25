---
title: "Hakyll deployment: Github -> CircleCi -> AWS CodeDeploy"
tags: haskell
---

Once upon a time, I wanted to start a blog. As a gifted procrastinator with a mild aversion to writing, I decided a good first step would be to build out a deployment pipeline such that I could go from version-controlled markdown files to deployed website. Of course I wouldn't want to run a bunch of commands every time I ran an update, so I used CircleCI and AWS CodeDeploy to set up automated deployments triggered by commits to the master branch. Of course I wouldn't want to manually handle all the ops tasks of setting up that AWS env via the console, so I used terraform to create a declarative description of the AWS env to which deployments would occur. At this point, having still not written more than a few words of actual blog post, I tweaked various bits of CSS, Html, added https support, et cetera. Finally, having no excuse not to actually write an article I decided to start by documenting this process.

<!--more-->

outstanding q: wait, am I using keter here still? IIRC I did play with that a bit
- let's try doing a test deploy and seeing what happens

tldr yes but only on master
version: 0.0
os: linux
files:
  - source: /lamassu-lifeboat.keter
    destination: /var/www/keter/incoming

### First, let's take a look at a high-level sketch of this setup.

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


[![CircleCI](https://circleci.com/gh/pkinsky/imminent-axolotl/tree/master.svg?style=svg)](https://circleci.com/gh/pkinsky/imminent-axolotl/tree/master)
