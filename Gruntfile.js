module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        sync: {
            main: {
                files: [
                    {cwd: 'src', src: './views/**', dest: 'bin/'},
                    {cwd: 'src', src: ['./public/**', '!./public/**/*.coffee'], dest: 'bin/'}
                ]
            }
        },
        watch: {
            app: {
                files: [
                    'src/public/**/*.coffee',
                    'src/components/**/*.coffee',
                    'src/lib/common/**/*.coffee'
                ],
                tasks: ['cjsx']
            },
            server: {
                files: [
                    'src/models/**/*.coffee',
                    'src/controllers/**/*.coffee',
                    'src/lib/**/*.coffee'
                ],
                tasks: ['coffee']
            },
            templates: {
                files: [
                    'src/views/**'
                ],
                tasks: ['sync']
            }
        },
        cjsx: {
            compile: {
                files: {
                    'bin/public/js/bundle.js': 'src/public/js/index.coffee'
                }
            }
        },
        coffee: {
            glob_to_multiple: {
                expand: true,
                flatten: false,
                cwd: 'src',
                src: [
                    './controllers/**/*.coffee',
                    './lib/**/*.coffee',
                    './models/**/*.coffee',
                    './oneoff/**/*.coffee',
                    './routes/**/*.coffee',
                    './tests/**/*.coffee',
                    './index.coffee'
                ],
                dest: 'bin',
                ext: '.js'
            }
        },
        nodemon: {
            dev: {
                script: 'bin/index.js',
                options: {
                    nodeArgs: ['--debug'],
                    watch: ['bin']
                }
            }
        }
    });

    grunt.loadNpmTasks('grunt-coffee-react');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-sync');
    grunt.loadNpmTasks('grunt-nodemon');

    grunt.registerTask('default', ['coffee']);
};