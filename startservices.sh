#! /bin/bash

#_Sinatra Nodes_______________
#   1)       Router: port 4567
#   2)    TweetHTML: port 8080
#   3)   FollowData: port 8081
#   4) TimelineData: port 8082
#   5)     Searcher: port 8083

# echo "Spinning up NanoTwitter and microservices..."
# echo "NanoTwitter and microservices are up and running!"

#_Prod Queues_____________________________________________________________________
#   1) new_tweet.searcher.tweet_data          Router --> Searcher
#   2)   new_tweet.follow.tweet_data          Router --> ??????????
#   3)        new_tweet.follower_ids      FollowData --> TimelineData + TweetHTML
#   3)          new_tweet.tweet_data          Router --> TweetHTML
#   4)               new_tweet.to_db          Router --> Router
#   5)      new_follow.timeline_data          Router --> TimelineData
#   5)      new_follow.sorted_tweets    TimelineData --> TweetHTML
#   6)              new_follow.to_db          Router --> Router
#   7)               new_follow.data          Router --> FollowData
#   8)                 searcher.html        Searcher --> TweetHTML

echo "Spinning up RabbitMQ server in background..."
rabbitmq-server &
echo "RabbitMQ server is up and running!"

#__Redis Instances____________________________________________________
#   1) TimelineHTML: port 6379       TweetHTML --> REDIS_TIMELINE_HTML
#   2)   SearchHTML: port 6382       TweetHTML --> REDIS_SEARCH_HTML
#   3)   EvenTweets: port 6384       TweetHTML --> REDIS_EVEN
#   4)    OddTweets: port 6383       TweetHTML --> REDIS_ODD
#   5)   FollowHTML: port 6380      FollowData --> REDIS_FOLLOW_HTML
#   6) TimelineData: port 6386    TimelineData --> (as "REDIS" in app)
#   7)   FollowData: port 6385   Router (seed) --> REDIS_FOLLOW_DATA
#   8)     UserData: port 6381   Router (seed) --> REDIS_USER_DATA
#   9)   SearchData: port 6387        Searcher -->

echo "Spinning up Redis servers in background processes..."
for i in $(seq 6379 6391); do redis-server --port $i & done
echo "Redis servers up and running!"

sleep 10

rake db:drop db:create db:dump:seed

for i in follow_data searcher timeline_data tweet_html nanotwitter
do
    cd ../$i
    ruby app.rb &
done

sleep 5
ruby cache_seeder.rb
