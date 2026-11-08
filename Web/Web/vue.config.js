module.exports = {
  devServer: {
    port: 8080
  },
  css: {
    loaderOptions: {
      sass: {
        implementation: require("sass")
      }
    }
  }
};
