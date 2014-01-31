# Copy this into the client to create a collection client side
@Lists = new Meteor.Collection 'lists'

@Lists.allow
  insert: (userId, list) ->
    if not userId?
      throw new Meteor.Error 400, "Cannot create lists unless logged in."
    _.extend list, userId: userId
  update: (userId, list, fieldNames, modifier) ->
    if list.userId isnt userId and not _.contains(_.pluck(list.users, '_id'), userId)
      throw new Meteor.Error 400, "Naughty, naughty. You can only update your own lists."
    true
  remove: (userId, list) ->
    if list.userId isnt userId
      throw new Meteor.Error 400, "Naughty, naughty. You can only delete your own lists."
    true

# Expose some methods we can call from client or server
Meteor.methods
  unDone: (listId, itemId, done) ->
    check listId, String
    check itemId, String
    check done, Boolean
    
    # Get the list from the id
    lists = Lists.find({_id: listId}).fetch()
    list = lists[0]
    
    itemIndex = _.indexOf(_.pluck(list.items, 'id'), itemId)
    
    # If itemIndex is -1, then the item does not exist
    if itemIndex is -1
      throw new Meteor.Error 400, "No such item"
    
    # On the server, use items.$.done to set the data
    if Meteor.isServer
      Lists.update
        _id: listId
        'items.id': itemId
      ,
        $set:
          'items.$.done': done
    # Hack a workaround on the client
    else
      modifier = {$set: {}}
      modifier.$set['items.' + itemIndex + '.done'] = done
      Lists.update listId, modifier

  # Take an email and find a user _id and best username
  findUserIdByEmail: (email) ->
    check email, String
    # Find the user in the database
    if Meteor.isServer
      user = Meteor.users.find
        $or: [
          'emails.address': email
        ,
          'services.google.email': email
        ,
          'services.google.email': email
        #,
        #  'services.github.email': email
        ]
      .fetch()
      if user.length isnt 1
        return false
      else
        # Find the best available username
        if user[0].services?.facebook?.username?
          username = user[0].services.facebook.username
        else if user[0].profile?.name?
          username = user[0].profile.name
        else if user[0].emails?[0].address?
          username = user[0].emails[0].address
        else
          username = false
        _id: user[0]._id
        username: username

if Meteor.isClient
  Meteor.startup () ->
    FlashMessages.configure
      autoHide: false
