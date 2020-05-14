'use strict';

var pkg = require('./package.json'),
  autoprefixer = require('gulp-autoprefixer'),
  browserify = require('browserify'),
  buffer = require('vinyl-buffer'),
  connect = require('gulp-connect'),
  csso = require('gulp-csso'),
  del = require('del'),
  ghpages = require('gh-pages'),
  gulp = require('gulp'),
  gutil = require('gulp-util'),
  path = require('path'),
  plumber = require('gulp-plumber'),
  rename = require('gulp-rename'),
  source = require('vinyl-source-stream'),
  stylus = require('gulp-stylus'),
  through = require('through'),
  uglify = require('gulp-uglify'),
  isDist = process.argv.indexOf('serve') === -1,
  // browserifyPlumber fills the role of plumber() when working with browserify
  browserifyPlumber = function(e) {
    if (isDist) throw e;
    gutil.log(e.stack);
    this.emit('end');
  };

var exec = require('gulp-exec');

 
gulp.task('pandoc', function() {
    var options = {
        continueOnError: false, // default = false, true means don't emit error event
        pipeStdout: true, // default = false, true means stdout is written to file.contents
        customTemplatingThing: "" // content passed to gutil.template()
    };
    var reportOptions = {
        err: false, // default = true, false means don't write err
        stderr: true, // default = true, false means don't write stderr
        stdout: false // default = true, false means don't write stdout
    };
    return gulp.src('src/*.txt')
        .pipe(exec("pandoc -s --mathjax -i -f markdown -t revealjs --template=./src/pandoc-bespoke.html -i <%= file.path %> -o -", options))
        .pipe(exec.reporter(reportOptions))
        .pipe(rename(function (path) {
            path.extname = ".html"
            }
        ))
        .pipe(gulp.dest('src/'))
});


gulp.task('js', ['clean:js'], function() {
  // see https://wehavefaces.net/gulp-browserify-the-gulp-y-way-bb359b3f9623
  return browserify('src/scripts/main.js').bundle()
    .on('error', browserifyPlumber)
    .pipe(source('src/scripts/main.js'))
    .pipe(buffer())
    .pipe(isDist ? uglify() : through())
    .pipe(rename('build.js'))
    .pipe(gulp.dest('dist/build'))
    .pipe(connect.reload());
});

gulp.task('html', ['clean:html'], function() {
  return gulp.src('src/index.html')
    .pipe(gulp.dest('dist'))
    .pipe(connect.reload());
});

gulp.task('css', ['clean:css'], function() {
  return gulp.src('src/styles/main.styl')
    .pipe(isDist ? through() : plumber())
    .pipe(stylus({ 'include css': true, 'hoist': true, paths: ['./node_modules'] }))
    .pipe(autoprefixer({ browsers: ['last 2 versions'], cascade: false }))
    .pipe(isDist ? csso() : through())
    .pipe(rename('build.css'))
    .pipe(gulp.dest('dist/build'))
    .pipe(connect.reload());
});

gulp.task('images', ['clean:images'], function() {
  return gulp.src('src/images/**/*')
    .pipe(gulp.dest('dist/images'))
    .pipe(connect.reload());
});

gulp.task('fonts', ['clean:fonts'], function() {
  return gulp.src('src/fonts/*')
    .pipe(gulp.dest('dist/fonts'))
    .pipe(connect.reload());
});

gulp.task('clean', function() {
  return del.sync('dist');
});

gulp.task('clean:html', function() {
  return del('dist/index.html');
});

gulp.task('clean:js', function() {
  return del('dist/build/build.js');
});

gulp.task('clean:css', function() {
  return del('dist/build/build.css');
});

gulp.task('clean:images', function() {
  return del('dist/images');
});

gulp.task('clean:fonts', function() {
  return del('dist/fonts');
});

gulp.task('connect', ['build'], function() {
  connect.server({ root: 'dist', host: 'localhost', port: process.env.PORT || 8080, livereload: true });
});

gulp.task('watch', function() {
  gulp.watch('src/**/*.html', ['html']);
  gulp.watch('src/scripts/**/*.js', ['js']);
  gulp.watch('src/styles/**/*.styl', ['css']);
  gulp.watch('src/images/**/*', ['images']);
  gulp.watch('src/fonts/*', ['fonts']);
  gulp.watch(['src/*.md', 'src/pandoc-bespoke.html', 'src/*.txt'], ['pandoc']);
});

gulp.task('publish', ['clean', 'build'], function(done) {
  ghpages.publish(path.join(__dirname, 'dist'), { logger: gutil.log }, done);
});

// old alias for publishing on gh-pages
gulp.task('deploy', ['publish']);

gulp.task('build', ['js', 'html', 'css', 'images', 'fonts', 'pandoc']);

gulp.task('serve', ['connect', 'watch']);

gulp.task('default', ['build']);
