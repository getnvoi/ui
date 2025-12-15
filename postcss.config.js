module.exports = {
  plugins: [
    require('postcss-import-ext-glob'),
    require('postcss-import'),
    require('postcss-nested'),
    require('cssnano')({ preset: 'default' }),
  ]
}
