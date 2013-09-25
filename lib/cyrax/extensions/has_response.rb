module Cyrax::Extensions
  module HasResponse
    extend ActiveSupport::Concern

    def add_error(error)
      @_errors ||= []
      @_errors << error
    end

    def assign_resource(resource_name, resource, options = {})
      resource = options[:decorator].decorate(resource) if options[:decorator]
      @_assignments ||= {}
      @_assignments[resource_name.to_sym] = resource
    end

    def add_error_unless(error, condition)
      add_error(error) unless condition
    end

    def add_errors_from(model)
      @_errors ||= []
      if model && model.errors.messages.present?
        model.errors.messages.each do |key, value|
          add_error "#{key}: #{value}"
        end
      end
    end

    def set_message(message)
      @_message = message
    end

    def response_name
      self.class.name.demodulize.underscore
    end

    def respond_with(result, options = {})
      name = options[:name] || response_name
      if respond_to?(:decorable?)
        options.merge!(decorable: decorable?, decorator_class: decorator_class)
        result = Cyrax::BasePresenter.present(result, options)
      end
      response = result.is_a?(Cyrax::Response) ? result : Cyrax::Response.new(name, result)
      response.message = @_message
      response.errors = @_errors
      response.assignments = @_assignments
      response
    end
  end
end
