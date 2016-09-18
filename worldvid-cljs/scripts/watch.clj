(require '[cljs.build.api :as b])

(b/watch "src"
  {:main 'worldvid-cljs.core
    :output-to "../priv/static/js/cljs/worldvid-cljs.js"
    :output-dir "../priv/static/js/cljs"
    :asset-path "/js/cljs"})
