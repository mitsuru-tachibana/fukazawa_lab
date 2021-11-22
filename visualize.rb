require 'csv'
require 'fileutils'
# require 'launchy'

def init
  FileUtils.mkdir_p('convert_csv/intermediates') unless FileTest.exist?('convert_csv/intermediates')
end

# rails cで取得したモデルのオブジェクトをプレーンなテキストとしてファイルに保存するメソッド
def obj_to_text(objects)
  File.open('convert_csv/intermediates/obj_to_text.txt', 'w') do |f_ott|
    objects.each do |object|
      # 引数として与えられたオブジェクトの一つ一つについて、属性とその値をファイルに出力する
      f_ott.puts(object.attributes)
    end
  end
end

def text_to_attr
  # ファイルを一行ずつ(オブジェクトを一つずつ)読み込み、','区切りで改行して新しいファイルに出力する
  File.open('convert_csv/intermediates/obj_to_text.txt', 'r') do |f_ott|
    File.open('convert_csv/intermediates/text_to_attr.txt', 'w') do |f_tta|
      f_ott.each_line(',') do |line|
        f_tta.puts(line)
      end
    end
  end
end

def attr_to_csv(objects)
  # text_to_attr.txtにてオブジェクトごとの行数を算出
  obj_lines = objects.first.attributes.length + 2
  file_lines = objects.length * obj_lines
  # 書き込み様のファイル名を作成
  class_name = objects.class.to_s.split('::')[0]
  file_name = "#{class_name}#{DateTime.now.strftime('_%y%m%d_%H%M%S')}.csv"
  # 属性と値がセットになっているファイルを読み込む
  File.open('convert_csv/intermediates/text_to_attr.txt', 'r') do |f_tta|
    # 書き込み様のCSVファイルを開く
    CSV.open("convert_csv/#{file_name}", 'w') do |f_atc|
      # 各オブジェクトの頭からの行数を保持
      f_tta.each_line do |line|
        # 現在の行が各オブジェクトの頭から何行目かを算出
        offset = f_tta.lineno % obj_lines
        # 各行の先頭と末尾の余計な文字を削除
        line = line.slice(1..line.length - 3)
        # 現在読み込み中の行数で条件分岐
        ## 各オブジェクトの下から4or2番目だったら("created_at", "updated_at"という文字列しかない)
        if offset == obj_lines - 3 || offset == obj_lines - 1
          # lineを=>で分割し、左側の文字列の””を取り除いてattrに格納
          attr = line.split('=>')[0].gsub(/"/, '')
          # 次の行を読み込み、先頭と末尾の余計な文字を削除してvalに格納
          n_line = f_tta.gets
          val = n_line.slice(1..n_line.length - 3)
          offset += 1
        ## その他の行だったら(属性と値がセットで一行に書かれている)
        else
          # 文字列を=>で分割し配列に格納
          arr = line.split('=>')
          # 分割した文字列の左側の””を削除してattrに格納
          attr = arr[0].gsub(/"/, '')
          val = if arr[1].length > 3
                  # 分割した文字列の右側の先頭と末尾の余計な文字を削除してvalに格納
                  arr[1].slice(1..arr[1].length - 2)
                else
                  arr[1]
                end
        end
        # csvファイルに格納
        f_atc << [attr, val]
        # if f_tta.lineno == file_lines
        #   f_atc << ['EOF']
        # elsif offset == obj_lines
        #   f_atc << ['*']
        # end
      end
    end
  end
  file_name
end

def convert_csv(objects)
  init
  obj_to_text(objects)
  text_to_attr
  attr_to_csv(objects)
end

def visualize(objects)
  file_name = convert_csv(objects)
  attr_num = objects.first.attributes.length
  array = []
  CSV.open("convert_csv/#{file_name}", 'r') do |csv|
    csv.each_slice(attr_num) do |entry|
      array << entry
    end
  end
  records = array.to_query('records')
  puts file_name
  puts records
  Launchy.open('https://www.youtube.com/')
  Launchy.open("hogehoge/visualize?#{records}%&file_name=#{file_name}")
end
