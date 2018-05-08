---
title: "Hakyll deployment: Github -> CircleCi -> AWS CodeDeploy"
tags: haskell
---

In this post I'll explain how to deploy a Hakyll blog using CircleCI and AWS CodeDeploy. This is meant as an alternative to the standard github.io approach, with the additional benefit of providing some experience that can then be transfered to deploying more complex applications to AWS.

<!--more-->


### First, let's take a look at a high-level sketch of this setup.

(diagram with Github -> CircleCI -> AWS CodeDeploy deployment group)


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
