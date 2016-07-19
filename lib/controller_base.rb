require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'
require_relative './session'
require_relative './flash'


class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "double render" if already_built_response?
    @res['Location'] = url
    @res.status = 302
    @already_built_response = true
    session
    @session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
      raise "double render" if already_built_response?
      @res.write(content)
      @res['Content-Type'] = content_type
      @already_built_response = true
      session
      @session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir_path = File.dirname(__FILE__)
    template_fname = File.join(
      dir_path, "..",
      "views", self.class.name.underscore, "#{template_name}.html.erb"
    )
    contents = File.read(template_fname)
    template = ERB.new(contents)
    result = template.result(binding)
    render_content(result, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash = Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)

    self.send(name)
    render(name.to_s) unless already_built_response?
  end
end
