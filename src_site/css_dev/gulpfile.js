const gulp = require('gulp');
      sass = require( 'gulp-sass' );
      $    = require('gulp-load-plugins')();
//      sassPaths = [ 'node_modules/flexboxgrid-sass/dist/flexboxgrid.css' ];

gulp.task('sass', () => {
    return gulp.src('./sass/**/*.scss')
        .pipe($.sass({
//            includePaths: sassPaths,
            outputStyle: 'compress'
        })
          .on('error', sass.logError))
        .pipe($.autoprefixer({
            overrideBrowserslist: ['last 2 versions']
        }))
        .pipe(gulp.dest('../css'));
});

gulp.task('sass:watch', () => {
    gulp.watch('./sass/**/*.scss', gulp.series('sass'));
});
