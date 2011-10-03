require_dependency 'search_controller'

module SearchControllerPatch
  def self.included(base)
    base.class_eval do
      alias_method :_index, :index unless method_defined? :_index

      def index
        _index

        if @results != nil
          @results.delete_if do |result|
            result.class == WikiPage && !User.current.can_view?(result)
          end
        end
      end

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

  SearchController.send(:include, SearchControllerPatch)
end
