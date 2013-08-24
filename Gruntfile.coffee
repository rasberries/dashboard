module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    run:
      default: preset: 'default'
      compile: preset: 'compile'
      server: preset: 'server'
      serveralt: params: ["-s", "-v", "-p", "8000"]
      
    watch:
      files: ["src/**/*"]
      tasks: ["run:compile"]

  grunt.registerMultiTask 'run', "Run the App", ->
    if @data.params then @params = @data.params
    else 
      @data.preset ?= @target
      switch @data.preset
        when "default" then @params = ["-s", "-c", "-v", "-p", "80"]
        when "altport" then @params = ["-s", "-c", "-v", "-p", "8000"]
        when "compile" then @params = ["-c", "-v"]
        when "server" then @params = ["-s", "-v", "-p", "80"]
    process.argv = @params
    require "./server.js"
    console.log @params, @params.indexOf "-s"
    if @params.indexOf "-s" > -1 then done = @async();

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-devtools'  

  grunt.registerTask "default", ["run"]
  grunt.registerTask "alternate", ["run:server", "watch" ]
  grunt.registerTask "superalternate", ["run:serveralt", "watch"]
  grunt.registerTask "serveralt", ["run:serveralt"]