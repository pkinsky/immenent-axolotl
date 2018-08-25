---
title: "Hakyll deployment: Github -> CircleCi -> AWS CodeDeploy"
tags: haskell
---


[![CircleCI](https://circleci.com/gh/pkinsky/imminent-axolotl/tree/master.svg?style=svg)](https://circleci.com/gh/pkinsky/imminent-axolotl/tree/master)


Once upon a time, I wanted to start a blog. As a gifted procrastinator with a mild aversion to writing, I decided a good first step would be to build out a deployment pipeline such that I could go from version-controlled markdown files to deployed website.

<!--more-->

This post will take you through how I did so while also functioning as a somewhat self-deprecating monument to the developer equivalent of constantly tweaking fonts and slide change animations instead of actually working on a presentation.

At this point, having still not written more than a few words of actual blog post, I tweaked various bits of CSS, Html, added https support, et cetera. Finally, having no excuse not to actually write an article I decided to start by documenting this process.

## Github

link to repo here

describe what's actually in repo (maybe also include links to the rest of this, use this as a table of contents - no dir for keter, though - actually, I can totally just skip any keter section - only really needs a few sentences)

- Static Content Generation: `/site`
- Yesod Server:`/lamassu-lifeboat` 
- Continuous Deployment: `/.cirleci`
- AWS Service Configuration: `/terraform`

## Static Content Generation

## Yesod Server

## Continuous Deployment

Of course I wouldn't want to run a bunch of commands every time I ran an update, so I used CircleCI and AWS CodeDeploy to set up automated deployments triggered by commits to the master branch. 

## AWS Service Configuration

- AWS code deploy
- used to deploy to a cluster of EC2 boxen
- all connected to a domain I own via route 53

