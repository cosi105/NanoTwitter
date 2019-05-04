describe 'RabbitMQ' do

  it 'can publish a new tweet' do
    new_tweet = {
      author_id: @ari.id,
      author_handle: @ari.handle,
      body: 'Scalability is the best!',
    }
    create_and_publish_tweet(new_tweet)
    sleep 3
    t = Tweet.last
    t.author_id.must_equal @ari.id
    t.author_handle.must_equal @ari.handle
    t.body.must_equal 'Scalability is the best!'

    REDIS_SEARCH_HTML.lrange('scalability', 0, -1).count.must_equal 1
  end

  it 'can publish a new follow' do
    follow_params = {
      follower_id: @brad.id,
      follower_handle: @brad.handle,
      followee_id: @ari.id,
      followee_handle: @ari.handle
    }
    create_and_publish_follow(follow_params)
    sleep 3
    @brad.followees.must_equal [@ari]
    @ari.followers.must_equal [@brad]
    REDIS_FOLLOW_HTML.lrange("#{@ari.id}:followers", 0, -1).must_equal ['<div class="user-container">@brad</div>']
    REDIS_FOLLOW_HTML.lrange("#{@brad.id}:followees", 0, -1).must_equal ['<div class="user-container">@ari</div>']
  end

  it 'can send a new tweet directly to the database' do
    new_tweet = {
      author_id: @ari.id,
      author_handle: @ari.handle,
      body: 'Scalability is the best!',
      created_on: DateTime.now.in_time_zone('UTC')
    }
    t = Tweet.create(new_tweet)
    new_tweet[:tweet_id] = t.id
    follow_params = {
      follower_id: @brad.id,
      follower_handle: @brad.handle,
      followee_id: @ari.id,
      followee_handle: @ari.handle
    }
    create_and_publish_follow(JSON.parse(follow_params.to_json))
    sleep 3
    rabbit_new_tweet_db_timelines(JSON.parse(new_tweet.to_json))
    sleep 3
    TimelinePiece.where(timeline_owner_id: @brad.id, tweet_id: t.id).count.must_equal 1
  end

  it 'can unfollow a user' do
    new_tweet = {
      author_id: @ari.id,
      author_handle: @ari.handle,
      body: 'Scalability is the best!',
      created_on: DateTime.now.in_time_zone('UTC')
    }
    t = Tweet.create(new_tweet)
    new_tweet[:tweet_id] = t.id
    follow_params = {
      follower_id: @brad.id,
      follower_handle: @brad.handle,
      followee_id: @ari.id,
      followee_handle: @ari.handle
    }
    create_and_publish_follow(JSON.parse(follow_params.to_json))
    sleep 3
    rabbit_new_tweet_db_timelines(JSON.parse(new_tweet.to_json))
    sleep 3
    TimelinePiece.where(timeline_owner_id: @brad.id, tweet_id: t.id).count.must_equal 1
  end

end
