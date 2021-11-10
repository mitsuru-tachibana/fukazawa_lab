obj_count = 0
line_count = 0
# rails cで取得したモデルのオブジェクトをプレーンなテキストとしてファイルに保存するメソッド
def obj_to_text(objects)
  File.open("obj_to_text.txt", "w") do |f_ott|
    objects.each do |object|
      # 引数として与えられたオブジェクトの一つ一つについて、属性とその値をファイルに出力する
      f_ott.puts(object.attributes)
      obj_count += 1
    end
  end
end

def text_to_attr
  # # 既存のファイルの中身をリセット
  # File.open("text_to_attr.txt", "w")
  # ファイルを一行ずつ(オブジェクトを一つずつ)読み込み、","区切りで改行して新しいファイルに出力する
  File.open("obj_to_text.txt", "r") do |f_ott|
    File.open("text_to_attr.txt", "w") do |f_tta|
      f_ott.each_line(",") do |line|
        f_tta.puts(line)
        line_count += 1
      end
    end
  end
end
  
def attr_to_csv
  # ファイルにおいて各オブジェクトが使っている行数の算出
  line_counts_of_obj = line_count / obj_count
  File.open("text_to_attr.txt", "r")do |f_tta|
    File.open("attr_to_csv.csv", "w")
  end
end

def object_to_csvfile()

end
