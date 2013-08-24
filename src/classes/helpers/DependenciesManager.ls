class DepMan extends IS.Object

  (@basePrefix = "", @deps = []) -> @echo "Activated DependenciesManager!"
  _require   : (module, prefix = "") ~>
    unless module.substr? then module = module * "/"
    str = "#{prefix}#{module}"
    if @deps[str] then return @deps[str]
    else 
      @deps[str] = require "#{@basePrefix}#{str}"
      return @deps["#{prefix}#{module}"]

  data       : (module, suffix = "") ~> @_require module, "data/#{suffix}"
  classes    : (module, suffix = "") ~> @_require module, "classes/#{suffix}"
  render     : (module, ...args) ~> (@data module, "views/").apply @, args
  doc        : (module) ~> @data "docs/"
  stylesheet : (module) ~> @data module, "stylesheets/"
  image      : (module) ~> @data module, "images/"
  font       : (module) ~> @data module, "fonts/"
  language   : (module) ~> @data module, "languages/"
  helper     : (module) ~> @classes module, "helpers/"
  controller : (module) ~> @classes module, "controllers/"
  model : (module) ~> @classes module, "models/"
  model      : (module) ~> @classes module, "models/"
  lib        : (module) ~> @classes module, "libs/"
  angular    : (module) ~> @classes module, "angular/"
  gesture    : (module) ~> @classes module, "gestures/"
  renderer   : (module) ~> @classes module, "renderers/"
  googleFont : (font, sizes, subsets = null) ~>
    names = font.split " "
    _s = @deps["#{font}"] = document.createElement "link"
    string =  "http://fonts.googleapis.com/css?family=#{names.join "+"}:#{sizes.join ","}"
    if subsets? then string += "&subset=#{subsets.join ","}"
    _s.setAttribute "href", string
    _s.setAttribute "rel", "stylesheet"
    _s.setAttribute "type", "text/css"
    document.head.appendChild _s
    _s

module.exports = DepMan
