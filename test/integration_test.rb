describe 'Integration Tests' do

  it 'can register a new user' do
    post '/register', name: 'Ari', handle: '@ari2', password: 'pitorules'
    sleep 3
    u = User.last
    u.name.must_equal 'Ari'
    u.handle.must_equal '@ari2'
    u.authenticate('pitorules').must_equal u
  end

  it 'requires a unique handle' do
    post '/register', name: 'Ari', handle: '@ari', password: 'pitorules'
    sleep 3
    User.last.authenticate('pitorules').must_equal false
  end

  it 'can log in' do
    resp = post '/login', handle: '@ari', password: '@ari'
    resp.status.must_equal 200
  end

  it 'requires the correct password' do
    resp = post '/login', handle: '@ari', password: '@ari2'
    resp.status.must_equal 401
  end

end
