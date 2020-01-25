require "../src/freed/mind"

#de Reworking of https://github.com/datanoise/mongo.cr#usage

focuses = Freed::Mind.new

focuses["example"].insert({ "name" => "James Bond", "age" => 37 })

focuses["example"].find({ "age" => { "$gt" => 30 } }) do |doc|
  puts "#{typeof(doc)}: #{doc}"
end
