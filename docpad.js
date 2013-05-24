module.exports = {
  plugins: {
    marked: {
      markedOptions: {
        gfm: true,
        sanitize: false
      }
    }
  },
  templateData: {
    // proxy Node require (e.g. for easy JSON files loading)
    require: function(pathFromSourceRoot) {
      return require(require('path').resolve(__dirname, 'src', pathFromSourceRoot));
    }
  }
};