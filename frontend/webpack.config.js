const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

const isProd = process.env.NODE_ENV === "production";

module.exports = {
  mode: isProd ? "production" : "development",
  entry: "./src/index.js",
  output: {
    path: path.resolve(__dirname, "../priv/static"),
    filename: "assets/app.js",
    publicPath: "/",
    clean: false
  },
  devtool: isProd ? "source-map" : "eval-source-map",
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: "babel-loader"
      },
      {
        test: /\.scss$/,
        use: [
          isProd ? MiniCssExtractPlugin.loader : "style-loader",
          "css-loader",
          "sass-loader"
        ]
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/index.html",
      filename: "index.html"
    }),
    ...(isProd
      ? [new MiniCssExtractPlugin({ filename: "assets/app.css" })]
      : [])
  ],
  devServer: {
    host: "::",
    port: 8080,
    allowedHosts: "all",
    historyApiFallback: true,
    proxy: [
      {
        context: ["/api", "/socket"],
        target: "http://127.0.0.1:4000",
        ws: true,
        changeOrigin: true
      }
    ]
  },
  resolve: {
    extensions: [".js"]
  }
};
