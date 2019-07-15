
# eAtlas · [![Build Status](https://travis-ci.org/layik/eAtlas.svg)](https://travis-ci.org/layik/eAtlas) [![Project Status: WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#)

<img width="100%" alt="Screenshot gif" src="https://user-images.githubusercontent.com/408568/60017431-9f0e3700-9680-11e9-8ec5-2973883a1681.gif"/>
<img width="100%" alt="eAtlas screen shot" src="https://user-images.githubusercontent.com/408568/61215554-2f312080-a703-11e9-9801-6fd744a7647d.png">

Currently this is just a “WIP” as we explore and gather requirements of
the project. There are some
[notes](https://github.com/layik/eAtlas/blob/master/notes/project_planning.md)
to read.

This is a [geopumber](https://github.com/ATFutures/geoplumber) app. That
means it is an R powered backend API (think Flask in Python) and a
ReactJS front end.

To build, from an R console:

``` r
library(geoplumber)
gp_build()
```

Before you run the app: \* you will need some preprocessed data, an RDS
called “ac\_joined\_wy\_2009-2017.Rds”. \* you will need a Mapbox API
key (will see if we can remove this) in `.env.local` file using variable
name: `REACT_APP_MAPBOX_ACCESS_TOKEN = 'API_KEY'`

Then you can run

``` r
library(geoplumber)
gp_plumb()
```

visit `localhost:8000`

or just run the front using: `npm i & npm start`
<img width="100%" alt="eAtlas screen shot" src="https://user-images.githubusercontent.com/408568/61232570-8694b800-a726-11e9-9fd0-eb0baa523c87.gif">

## deploy with docker

Repo contains Dockerfile for production.
