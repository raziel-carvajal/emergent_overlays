const gulp = require('gulp')
const nodemon = require('gulp-nodemon')

gulp.task('start', () => {
  nodemon({
    script: './index',
    ext: 'js html'
  })
})

gulp.task('default', ['start'])
