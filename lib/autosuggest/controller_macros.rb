require 'yajl'

module Autosuggest
  module ControllerMacros
    # when called, you must add a custom route for action like this:
    # resources :products do
    #   get :autosuggest_brand_name, :on => :collection
    # end
    def autosuggest(object, name, options={})
      options[:display]     ||= name
      options[:order]       ||= "#{name} ASC"
      options[:limit]       ||= 10
      options[:name]          = name

      # allow specifying fully qualified class name for model object
      class_name = options[:class_name] || object

      define_method "autosuggest_#{object}_#{name}" do
        options.merge!(:query => params[:query], :object => objectify(class_name), :like_clause => resolve_like_clause)
        results = db_store(class_name).query(options)
        render :json => Yajl::Encoder.encode(results.map{|r| {:name => r.send(options[:display]), :value => r.id.to_s}})
      end
    end
  end
end
