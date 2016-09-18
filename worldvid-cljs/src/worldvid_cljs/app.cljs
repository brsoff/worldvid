(ns worldvid-cljs.app
  (:require [reagent.core :as r]
            [ajax.core :refer [GET]]
            [clojure.walk :as walk]
            [worldvid-cljs.fixtures :as fixtures]))

(enable-console-print!)

(def state (r/atom {:countries ()
                    :videos ()
                    :selected-country ""
                    :theater-open false
                    :current-video {}}))

(defn handle-countries-response [response]
  (swap! state assoc :countries 
         (walk/keywordize-keys (get response "countries"))))

(defn handle-videos-response [response]
  (swap! state assoc :videos 
         (walk/keywordize-keys (get response "videos"))))

(defn embed-url [id]
  (str "https://youtube.com/embed/" id))

(defn fetch-country-data
  ([] (GET "/api/countries" {:handler handle-countries-response})) 
  ([id] (GET (str "/api/countries/" id "/videos") 
             {:handler handle-videos-response})))

(defn country [c]
  [:option {:value (get c :id)} (get c :name)])

(defn update-selected-country [id]
  (swap! state assoc :selected-country id))

(defn on-country-select [e]
  (let [id e.target.value]
    (update-selected-country id)
    (fetch-country-data id)))

(defn menu []
  [:div {:class "menu"}
   [:div {:class "menu-inner"}
    [:select 
     {:value (get @state :selected-country)
      :on-change on-country-select}
     [:option {:value ""} "Select country..."]
    (for [c (get @state :countries)]
      ^{:key (get c :id)} [country c])]]])

(defn img-src-for [url]
  (if (nil? url) fixtures/default-thumb-url url))                                                 
(defn open-theater []
  (swap! state assoc :theater-open true))

(defn set-current-video [video]
  (swap! state assoc :current-video video))

(defn play-video [video]
  (open-theater)
  (set-current-video video))

(defn theater-screen []
  (let [video (get @state :current-video)]
    [:div {:class "theater-screen"}
     [:iframe {:src (embed-url (get video :youtubeId))
               :frameBorder 0
               :allowFullScreen true}]]))

(defn theater []
  [:div {:class 
         (str "theater-container" 
              (if (get @state :theater-open) " open" ""))}
   [:a {:class "back" 
        :href "#" 
        :on-click #(swap! state assoc :theater-open false)}]
   [theater-screen]])

(defn video [v]
  (let [{:keys [:name :thumbUrl :category :top]} v]
   [:div {:class (str "video" (if top " top" ""))}
    [:a [:img 
         {:src (img-src-for thumbUrl)
          :on-click #(play-video v)}]]
    [:a {:href "#" :on-click #(play-video v)}
     [:h4 (str "[" category "] " name)]]]))

(defn videos []
   (let [video-cats 
         (sort-by 
           #(count (second %)) 
           #(> %1 %2)
           (group-by :category (get @state :videos)))]
    [:div {:class "videos"}
     (for [vc video-cats]
       (let [cat-name (first vc)]
         ^{:key cat-name} [:div {:class "video-category"} 
                  [:h3 cat-name] 
                  (for [vids (sort-by :position (second vc))] 
                    ^{:key (get v :id)} [video vids])]))]))

(defn app []
  (fetch-country-data)
  (fn []
    [:div {:class "app"} 
     [menu] 
     [videos]
     [theater]]))

(defn mount-app []
  (r/render-component [app] (.getElementById js/document "app")))

