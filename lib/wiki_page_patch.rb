require_dependency 'wiki_page'

module WikiPagePatch
  def self.included(base)
    base.class_eval do
      has_many :permissions, :class_name => 'WikiPageUserPermission'
      after_create :role_creator
    end

    def leveled_permissions(level)
      WikiPageUserPermission.find(:all, :conditions => { :wiki_page_id => id, :level => level })
    end

    def users_by_level(level)
      users = Array.new
      leveled_permissions(level).each do |permission|
        users << permission.user
      end
      users
    end

    def users_without_permissions
      project.users - users_with_permissions
    end

    def users_with_permissions
      users = Array.new
      WikiPageUserPermission.find(:all, :conditions => { :wiki_page_id => id }).each do |permission|
        users << permission.user
      end
      users
    end

    def members_without_permissions
      project.members - members_with_permissions
    end

    def members_with_permissions
      members_wp = Array.new
      permissions.each do |permission|
        members_wp << permission.member
      end
      members_wp
    end

  private
    def role_creator
      member = self.wiki.project.members.find_by_user_id(User.current.id)
      WikiPageUserPermission.create(:wiki_page_id => id, :level => 3, :member_id => member.id) unless member.nil?
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

  WikiPage.send(:include, WikiPagePatch)
end
