stores_data = [
  { name: "カフェ オリゾンテ",      image_url: "https://images.unsplash.com/photo-1559925393-8be0ec4767c8?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "ロースタリー ヒナタ",     image_url: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=2047&auto=format&fit=crop", smoking: false },
  { name: "珈琲処 こもれ日",        image_url: "https://images.unsplash.com/photo-1453614512568-c4024d13c247?q=80&w=1932&auto=format&fit=crop", smoking: false },
  { name: "テラッツァ 代官山",       image_url: "https://images.unsplash.com/photo-1521017432531-fbd92d768814?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "ブルーベル コーヒー",     image_url: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "蔵前珈琲店",             image_url: "https://images.unsplash.com/photo-1445116572660-236099ec97a0?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "カフェ・ロンド",          image_url: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=2070&auto=format&fit=crop", smoking: true  },
  { name: "喫茶 しずく",            image_url: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "アウトドアコーヒー 翠",   image_url: "https://images.unsplash.com/photo-1600093463592-8e36ae95ef56?q=80&w=2070&auto=format&fit=crop", smoking: true  },
  { name: "コーヒースタンド 朝陽",   image_url: "https://images.unsplash.com/photo-1517705008128-361805f42e86?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "喫茶 ことり",            image_url: "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?q=80&w=2069&auto=format&fit=crop", smoking: false },
  { name: "カフェ・ブランシュ",      image_url: "https://images.unsplash.com/photo-1453614512568-c4024d13c247?q=80&w=2089&auto=format&fit=crop", smoking: false },
  { name: "テラス珈琲 海風",         image_url: "https://images.unsplash.com/photo-1511081692775-05d0f180a065?q=80&w=2073&auto=format&fit=crop", smoking: true  },
  { name: "コーヒーラボ 鶯谷",       image_url: "https://images.unsplash.com/photo-1498804103079-a6351b050096?q=80&w=2187&auto=format&fit=crop", smoking: false },
  { name: "珈琲と読書 栞",          image_url: "https://images.unsplash.com/photo-1507133750040-4a209f4f9d7e?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "喫茶 むすび",            image_url: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "カフェ ノルテ",           image_url: "https://images.unsplash.com/photo-1464979681340-bdd28a61699e?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "深煎り珈琲 燈",          image_url: "https://images.unsplash.com/photo-1525610553991-2bede1a236e2?q=80&w=2070&auto=format&fit=crop", smoking: true  },
  { name: "コーヒーと時間 庵",       image_url: "https://images.unsplash.com/photo-1473093226555-e4f8c1b8c54f?q=80&w=2070&auto=format&fit=crop", smoking: false },
  { name: "テラス喫茶 空と風",       image_url: "https://images.unsplash.com/photo-1543332164-6e82f355badc?q=80&w=2070&auto=format&fit=crop", smoking: true  }
]

stores_data.each do |data|
  Store.find_or_create_by!(name: data[:name]) do |store|
    store.image_url = data[:image_url]
    store.smoking   = data[:smoking]
  end
end

puts "#{Store.count}店舗のシードが完了しました"
