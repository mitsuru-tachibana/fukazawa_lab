$obj_count = 0
$line_count = 0
# rails cで取得したモデルのオブジェクトをプレーンなテキストとしてファイルに保存するメソッド
def obj_to_text(objects)
  File.open("obj_to_text.txt", "w") do |f_ott|
    objects.each do |object|
      # 引数として与えられたオブジェクトの一つ一つについて、属性とその値をファイルに出力する
      f_ott.puts(object.attributes)
      $obj_count += 1
      # puts($obj_count)
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
        $line_count += 1
        puts($line_count)
      end
    end
  end
end
  
def attr_to_csv
  # ファイルにおける各オブジェクトあたりの行数
  puts($line_count, $obj_count)
  obj_lines = $line_count / $obj_count
  # 属性と値がセットになっているファイルを読み込む
  File.open("text_to_attr.txt", "r")do |f_tta|
  # 書き込み様のCSVファイルを開く
    File.open("attr_to_csv.csv", "w") do |f_atc|
      # 各オブジェクトの頭からの行数を保持
      f_tta.each_line do |line|
        len = line.length
        # 各オブジェクトの頭から何行目かで条件分岐
        line.slice(2..len-2)
        if ((f_tta.lineno % obj_lines) == (obj_lines - 3)) then
          
        elsif (f_tta.lineno % obj_lines == (obj_lines - 2)) then
          
        elsif (f_tta.lineno % obj_lines == (obj_lines - 1)) then
          
        elsif (f_tta.lineno % obj_lines == 0) then
        else
          arr = line.split("=>")
        end
        puts(line)
      end
    end
  end
end

def convert_csv()

end
