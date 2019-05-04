# NanoTwitter
#### Ari Carr (acarr@brandeis.edu), Yang Shang (yangshang@brandeis.edu), Brad Nesbitt (bknesbitt@brandeis.edu)
--

### All associated repos

#### [NanoTwitter](https://github.com/cosi105/nanotwitter)

[![Codeship Status for cosi105/nanotwitter](https://app.codeship.com/projects/975b6f10-5041-0137-12f8-36c930881de3/status?branch=master)](https://app.codeship.com/projects/339953)
[![Maintainability](https://api.codeclimate.com/v1/badges/5da89ae8dc04ad73e36a/maintainability)](https://codeclimate.com/github/cosi105/nanotwitter/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/5da89ae8dc04ad73e36a/test_coverage)](https://codeclimate.com/github/cosi105/nanotwitter/test_coverage)

#### [Load Balancer](https://github.com/cosi105/load_balancer)

[![Codeship Status for cosi105/load_balancer](https://app.codeship.com/projects/1d87d2d0-4f2c-0137-954e-36459708d7f5/status?branch=master)](https://app.codeship.com/projects/339601)
[![Maintainability](https://api.codeclimate.com/v1/badges/e95611d345aac691dc53/maintainability)](https://codeclimate.com/github/cosi105/load_balancer/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/e95611d345aac691dc53/test_coverage)](https://codeclimate.com/github/cosi105/load_balancer/test_coverage)

#### [Follow Data](https://github.com/cosi105/follow_data)

[![Codeship Status for cosi105/follow_data](https://app.codeship.com/projects/e70e2fd0-4adb-0137-db99-5e2db24b4609/status?branch=master)](https://app.codeship.com/projects/338630)
[![Maintainability](https://api.codeclimate.com/v1/badges/030697af6f74243f7b2a/maintainability)](https://codeclimate.com/github/cosi105/follow_data/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/030697af6f74243f7b2a/test_coverage)](https://codeclimate.com/github/cosi105/follow_data/test_coverage)

#### [Searcher](https://github.com/cosi105/searcher)

[![Codeship Status for cosi105/searcher](https://app.codeship.com/projects/a08bef20-4aae-0137-111f-3ef76e2b4548/status?branch=master)](https://app.codeship.com/projects/338620)
[![Maintainability](https://api.codeclimate.com/v1/badges/4cc4fb45232fbd957657/maintainability)](https://codeclimate.com/github/cosi105/searcher/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/4cc4fb45232fbd957657/test_coverage)](https://codeclimate.com/github/cosi105/searcher/test_coverage)

#### [Timeline Data](https://github.com/cosi105/timeline_data)

[![Codeship Status for cosi105/timeline_data](https://app.codeship.com/projects/696c2fd0-4c17-0137-d772-0a018d266758/status?branch=master)](https://app.codeship.com/projects/338763)
[![Maintainability](https://api.codeclimate.com/v1/badges/684bc84fd01743745a03/maintainability)](https://codeclimate.com/github/cosi105/timeline_data/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/684bc84fd01743745a03/test_coverage)](https://codeclimate.com/github/cosi105/timeline_data/test_coverage)

#### [Tweet HTML](https://github.com/cosi105/tweet_html)

[![Codeship Status for cosi105/tweet_html](https://app.codeship.com/projects/cfedf360-4ad7-0137-b293-7e643328ef00/status?branch=master)](https://app.codeship.com/projects/338629)
[![Maintainability](https://api.codeclimate.com/v1/badges/0e9369f1900877991f67/maintainability)](https://codeclimate.com/github/cosi105/tweet_html/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0e9369f1900877991f67/test_coverage)](https://codeclimate.com/github/cosi105/tweet_html/test_coverage)

--

### Background

NanoTwitter is a Twitter-like web applicable built by Ari Carr, Yang Shang, and Brad Nesbitt as a case study in software engineering for scalability. In this section, we'll provide a brief explanation for our approach to designing its architecture.

We wanted to attempt some of the strategies that the actual Twitter architecture leverages in the real world. Though a full explanation can be found [elsewhere online](https://www.infoq.com/presentations/Real-Time-Delivery-Twitter), as a refresher, here is an overview of their architecture and the flow of data following a new Tweet:
<a href="https://cl.ly/269a483263d2" target="_blank"><img src="https://d3r69eeiwn2k86.cloudfront.net/items/0B1H431g0B2002083H3R/Image%202019-05-03%20at%2011.10.25%20PM.png" style="display: block;height: 500px;width: auto;"/></a>

We were especially interested in the path depicting how the expensive write process of propagating a new Tweet is delegated to a "fan out" which, is responsible updating a layer of Redis caches. This Redis layer, in turn, pre-caches user timelines to optimize for reading/requesting.

**We set out to see whether we could follow similar principles to design a "Nano"-Twitter architecture would be scalable while optimizing for fast Timeline reads in particular...**

--

### Architecture Objectives
* Fast reads.
* Non-blocking writes wherever possible.
* “_Caches supported by microservices_,” not “_microservices backed by caches_.”
* Scale out, by adding more nodes and sharding caches as needed.
* Delegate expensive cache writes to microservices.
* Use only free services

With these in mind, we produced the architecture shown below, which illustrates the write path for a new Tweet:

<a href="https://cl.ly/92eb35fcd055" target="_blank"><img src="https://d3r69eeiwn2k86.cloudfront.net/items/2o183w0p0U3U1L122g0A/Image%202019-05-03%20at%2011.14.20%20PM.png" style="display: block;height: 500px;width: auto;"/></a>

* **Microservices** (blue) are written in Ruby (Sinatra).
* **Caches** (red) are Redis instances.
* **Data** flows between microservices (turqouise & green arrows) via message queues implemented with RabbitMQ.
* Relational data (grey) is stored in a Postgres Database.


Below is a mapping of the communications among services via RabbitMQ:

<a href="https://cl.ly/17d354e41f7a" target="_blank"><img src="https://d3r69eeiwn2k86.cloudfront.net/items/1b2B2d2T0a2s2F3q0v0e/Image%202019-05-03%20at%2011.22.05%20PM.png" style="display: block;height: 250px;width: auto;"/></a>
	
As data flows out from the Router node to microservices via message queues, those services shoulder the more expensive computations of the write process (such as determining which users' timelines need to be updated with a new Tweet). These ultimately write to a layer of Redis instances as shown below:

<a href="https://cl.ly/43da320e644a" target="_blank"><img src="https://d3r69eeiwn2k86.cloudfront.net/items/221x2Z1r3I1W1f1g0u3h/Image%202019-05-03%20at%2011.25.50%20PM.png" style="display: block;height: 250px;width: auto;"/></a>

Note that several caches hold pre-rendered HTML for fast-as-possible reads in response to GET requests for timelines, search results, followers, etc.

--

### How to run NanoTwitter on your machine:

For convenience, we've included a bash script in the repo for Router that spins-up everything you'll need: [`nanotwitter/startservices.sh`](https://github.com/cosi105/nanotwitter/blob/master/startservices.sh). This script will load all necessary instances of Redis, RabbitMQ, and Sinatra, and it will also take care of downloading a seed dataset into both the database and all relevant caches. It will take roughly a minute to run, and when the script terminates, you'll be ready to access NanoTwitter at [http://localhost:4567](http://localhost:4567).