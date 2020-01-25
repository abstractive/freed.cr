require "artillery"
require "artillery/mountpoint/shoulder"
require "artillery/launcher/bazooka"
require "../src/freed/thought"

class MetaExample < Artillery::Shot

  vector :get, "/has_meta", focuses(:proposals, :participants, :presences)

  def get
    success_response "Has meta: #{Time.now.to_s(Gnosis::TIMESTAMP)} Focuses? #{focus}"
  end

end

class NoMetaExample < Artillery::Shot

  vector :get, "/no_meta"

  def get
    success_response "No meta: #{Time.now.to_s(Gnosis::TIMESTAMP)} Focuses? #{focus}"
  end

end

spawn do
  Artillery::Shoulder.run
end

Artillery::Bazooka.run