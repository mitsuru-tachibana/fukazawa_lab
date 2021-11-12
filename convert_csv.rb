# rails cで取得したモデルのオブジェクトをプレーンなテキストとしてファイルに保存するメソッド
def obj_to_text(objects)
  File.open('obj_to_text.txt', 'w') do |f_ott|
    objects.each do |object|
      # 引数として与えられたオブジェクトの一つ一つについて、属性とその値をファイルに出力する
      f_ott.puts(object.attributes)
    end
  end
end

def text_to_attr
  # ファイルを一行ずつ(オブジェクトを一つずつ)読み込み、','区切りで改行して新しいファイルに出力する
  File.open('obj_to_text.txt', 'r') do |f_ott|
    File.open('text_to_attr.txt', 'w') do |f_tta|
      f_ott.each_line(',') do |line|
        f_tta.puts(line)
      end
    end
  end
end

def attr_to_csv(objects)
  # text_to_attr.txtにてオブジェクトごとの行数を算出
  obj_lines= objects.first.attributes.length + 2
  puts(obje_lines)
  # 属性と値がセットになっているファイルを読み込む
  File.open('text_to_attr.txt', 'r') do |f_tta|
    # 書き込み様のCSVファイルを開く
    File.open('attr_to_csv.csv', 'w') do |f_atc|
      # 各オブジェクトの頭からの行数を保持
      f_tta.each_line do |line|
        # 現在の行が各オブジェクトの頭から何行目かを算出
        offset = f_tta.lineno % obj_lines
        # 各行の先頭と末尾の余計な文字を削除
        line = line.slice(1..line.length - 3)
        puts(line)
        # offsetで条件分岐
        ## 各オブジェクトの下から4or2番目だったら("created_at", "updated_at"という文字列しかない)
        if offset == obj_lines - 3 || offset == obj_lines - 1
          attr = line.split('=>')[0].gsub(/"/, '')
          val = f_tta.gets.slice(1..len - 3) 
        ## 各オブジェクトの下から3or1番目だったら(実際の作成日or更新日が記録されている)
        elsif offset == obj_lines - 2 || offset == 0
          next
        ## その他の行だったら(属性と値がセットで一行に書かれている)
        else
          arr = line.split('=>')
          attr = arr[0].gsub(/"/, '')
          val = arr[1].slice(1..arr[1].length - 2)
        end
        f_atc << [attr, val]
      end
    end
  end
end

def convert_csv(objects)
  obj_to_text(objects)
  text_to_attr
  attr_to_csv(objects)
end
