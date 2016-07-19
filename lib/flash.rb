require 'json'

class Flash
  def initialize(req)
    @data = req.cookies["_flash"].nil? ? {} : JSON.parse(req.cookies["_flash"])
  end

  def [](key)
    @data[key]
  end

  def []=(key, array)
    @data[key] = array
  end

  def store_flash(res)
    res.set_cookie("_flash", {path: '/', value: @data.to_json})
  end
end
