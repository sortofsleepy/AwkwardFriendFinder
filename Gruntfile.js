/**
 *	@fileoverview
 *	Gruntfile for Matchstick. Compiles
 *	everything together.
 *
 */

module.exports = function(grunt){

	var base = __dirname + "/public/static/";
	var js_dir = base + "/js/";
	var css_dir = base + "css/";
	var scss_dir = base + "/scss/";

	grunt.initConfig({
		pkg:grunt.file.readJSON("package.json"),


        /*======== CSS =============*/
		compass: {
			dev:    {
				options: {
					// Output locations
					cssDir:                  css_dir,
					// Source locations
					sassDir:                 scss_dir,
					outputStyle:             'expanded'             // nested, expanded, compact, compressed
				}
			},

            production:{
                // Output locations
                cssDir:                  css_dir,

                // Source locations
                sassDir:                 scss_dir,
                //imagesDir:               'www.playbook.com/nexus/public/stylesheets/images',
                //javascriptsDir:          'www.playbook.com/nexus/public/js',

                // Other
                //httpGeneratedImagesPath: '/nexus/public/stylesheets/images',

                outputStyle:             'compressed'             // nested, expanded, compact, compressed
            }
		},
		watch: {
			options: {
				livereload: true
			},



			css:     {
				files: [
					scss_dir + '/main.scss',
                    scss_dir + '/_*.scss',
					scss_dir + '/**/*.scss',
					scss_dir + '/**/**/*.scss',
					scss_dir + '/**/**/**/*.scss'
				],
				tasks: ['compass:dev']
			}

		}
	});
//
	grunt.loadNpmTasks("grunt-contrib-uglify");
	grunt.loadNpmTasks('grunt-contrib-watch' );
	grunt.loadNpmTasks('grunt-contrib-compass' );

	grunt.registerTask( 'default',["compass:dev"]);


    /**
     * Package for production
     */
    function packageForProd(){

    }

};//end gruntfile