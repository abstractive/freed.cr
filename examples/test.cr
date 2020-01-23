require "artillery"
require "artillery/mountpoint/shoulder"
require "artillery/launcher/bazooka"

require "../src/freed/overrides/artillery"

class MetaExample < Artillery::Shot

  vector :get, "/has_meta", focuses(:one, :two, :three)

  def get
    success_response "Has meta: #{Time.now}"
  end

end

class NoMetaExample < Artillery::Shot

  vector :get, "/no_meta"

  def get
    success_response "No meta: #{Time.now}"
  end

end

spawn do
  Artillery::Shoulder.run
end

Artillery::Bazooka.run