require_dependency 'member'

module MemberPatch
  def self.included(base)
    base.class_eval do
      has_many :wiki_page_user_permissions
    end
  end
end

require 'dispatcher'
  Dispatcher.to_prepare do
    begin
      require_dependency 'application'
    rescue LoadError
      require_dependency 'application_controller'
    end

  Member.send(:include, MemberPatch)
end
