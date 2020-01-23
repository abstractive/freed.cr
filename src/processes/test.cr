require "../freed"

#de Reworking of https://github.com/datanoise/mongo.cr#usage

this = Freed::Mind.new

this["spies"].insert({ "name" => "James Bond", "age" => 37 })

this["spies"].find({ "age" => { "$gt" => 30 } }) do |doc|
  puts typeof(doc)    # => BSON
  puts doc
end
