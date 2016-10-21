## This test written in mocha+should.js
should = require('./../init');
describe 'crud edge:', () ->
  db = null
  User = null
  Friend = null

  before (done) ->
    db = getDataSource()

    User = db.define('User', {
      name: {type: String}
      email: {type: String},
      age: Number,
      fullId: {type: String, _id: true}
    }, updateOnLoad: true);

    Friend = db.define('Friend', {
      _id: {type: String, _id: true},
      _from: {type: String, _from: true, required: true},
      _to: {type: String, _to: true, required: true},
      label: {type: String}
    }, {updateOnLoad: true, arangodb: { edge: true}});

    db.automigrate(done);

  beforeEach (done) ->
    User.destroyAll ->
      Friend.destroyAll(done)

  after (done) ->
    User.destroyAll ->
      Friend.destroyAll(done)

  it 'create', (done) ->
    User.create [{name: 'Matteo'}, {name: 'Antonio'}], (err, user) ->
      should.not.exist(err)
      user.should.have.length(2)
      Friend.create {_from: user[0].fullId, _to: user[1].fullId, label: 'friend'}, (err, friend) ->
        should.not.exist(err)
        should.exist(friend)
        should.exist(friend.id)
        should.exist(friend._id)
        friend._from.should.equal(user[0].fullId)
        friend._to.should.equal(user[1].fullId)
        friend.label.should.equal('friend')

        done()

  it 'findById', (done) ->
    User.create [{name: 'Matteo1'}, {name: 'Antonio1'}], (err, user) ->
      should.not.exist(err)
      user.should.have.length(2)
      Friend.create {_from: user[0].fullId, _to: user[1].fullId, label: 'friend'}, (err, friend) ->
        should.not.exist(err)
        should.exist(friend)
        should.exist(friend.id)
        should.exist(friend._id)
        friend._from.should.equal(user[0].fullId)
        friend._to.should.equal(user[1].fullId)
        friend.label.should.equal('friend')
        Friend.findById friend.id, (err, f) ->
          should.not.exist(err)
          should.exist(f)
          f.id.should.equal(friend.id)

          done()

  it 'find', (done) ->
    Friend.create {_from: 'User/EDGE_FROM', _to: 'User/EDGE_TO1', label: 'friend'}, (err, friend) ->
      should.not.exist(err)
      should.exist(friend)
      should.exist(friend.id)
      should.exist(friend._id)
      friend._from.should.equal('User/EDGE_FROM')
      friend._to.should.equal('User/EDGE_TO1')
      friend.label.should.equal('friend')
      Friend.create {_from: 'User/EDGE_FROM', _to: 'User/EDGE_TO2', label: 'friend'}, (err, friend) ->
        should.not.exist(err)
        should.exist(friend)
        should.exist(friend.id)
        should.exist(friend._id)
        friend._from.should.equal('User/EDGE_FROM')
        friend._to.should.equal('User/EDGE_TO2')
        friend.label.should.equal('friend')
        Friend.find {where : {_from: 'User/EDGE_FROM', _to: 'User/EDGE_TO1', label: 'friend'}}, (err, f) ->
          should.not.exist(err)
          should.exist(f)
          f.should.be.instanceof(Array).and.have.lengthOf(1);
          f[0]._from.should.equal('User/EDGE_FROM')
          f[0]._to.should.equal('User/EDGE_TO1')
          f[0].label.should.equal('friend')

          done()
