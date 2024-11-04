module Static
end

require "frozen_record"

FrozenRecord::Base.auto_reloading = true
FrozenRecord::Base.base_path = "./_data"

require_relative "./static/conference"
require_relative "./static/meetup"
require_relative "./static/meetup_group"
