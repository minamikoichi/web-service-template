module.exports = (grunt) ->

  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-includes'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    dist: '../../../dist/teck'    
    buildtime: '<%= grunt.template.today("yyyy-mm-dd-h-MM-ss") %>'
    bower:
      install:
        options:
          targetDir: 'js/lib',
          layout: 'byType',
          verbose: false,
          cleanTargetDir: true,
          cleanBowerDir: true
    coffee:
      compile:
        options:
          join: true
        files:
          '<%= dist %>/js/teck.js' : [
            'js/teck-mv.coffee',
            'js/teck.coffee'
          ]
    uglify:
      mytarget:
        options:
          mangle: false
          banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd-h-MM-ss") %> */\n'        
        files:
          '<%= dist %>/js/teck.dep.min.js' : [
            'js/lib/jquery/jquery.js',
            'js/lib/underscore/underscore-min.js',
            'js/lib/backbone/backbone.js',
            'js/lib/bootstrap/bootstrap.js',
            'js/lib/knockout.js/knockout.js',
            'js/lib/isotype/index.js'
          ]
    cssmin:
      add_banaer:
        options: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd-h-MM-ss") %> */\n'
        files:
          '<%= dist %>/css/teck.dep.css' : [
            'js/lib/font-awesome/css/font-awesome.min.css',            
            'js/lib/bootstrap/bootstrap.css'
          ],
          '<%= dist %>/css/teck.css' : [
            'css/*.css'
          ]
    copy:
      main:
        files: [
          expand: true
          flatten: true
          src: 'img/*'
          dest: '<%= dist %>/img/'
        , 
          expand: true
          flatten: true
          src: 'js/lib/font-awesome/fonts/*'
          dest: '<%= dist %>/fonts/'
        ]
    clean:
      options:
        force: true
      build: 
        ['<%= dist %>/js','<%= dist %>/img','<%= dist %>/css']
  
  grunt.registerTask 'default' , ['clean' ,'bower' , 'coffee', 'uglify' , "cssmin", "copy"]
