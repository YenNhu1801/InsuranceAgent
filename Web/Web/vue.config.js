module.exports = {
  devServer: {
    port: 8080
  },
  // Vue CLI 3 turns this on when the machine has more than one CPU.
  // This release only uses it as a flag; the minifier below is separate.
  parallel: false,
  css: {
    loaderOptions: {
      sass: {
        implementation: require("sass")
      }
    }
  },
  configureWebpack: config => {
    const minimizers = config.optimization && config.optimization.minimizer
    if (!minimizers) return
    // uglifyjs-webpack-plugin 1.2.7 with parallel:true starts worker-farm
    // children. On Node 22 those children keep the event loop open after
    // webpack prints "Build complete", so `npm run build` never exits
    // and Docker stays inside RUN. In-process minify does not leave them.
    minimizers.forEach(plugin => {
      if (plugin && plugin.options && plugin.options.parallel) {
        plugin.options.parallel = false
      }
    })
  }
}
