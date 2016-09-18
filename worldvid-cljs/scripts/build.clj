(require '[cljs.build.api :as b])

(println "Building ...")

(let [start (System/nanoTime)]
  (b/build "src"
    {:main 'worldvid-cljs.core
     :output-to "../priv/static/js/cljs/worldvid-cljs.js"
     :output-dir "../priv/static/js/cljs"
     :asset-path "/js/cljs"
     :optimizations :none
     :cache-analysis true
     :source-map true
     :verbose true})
  (println "... done. Elapsed" (/ (- (System/nanoTime) start) 1e9) "seconds"))


