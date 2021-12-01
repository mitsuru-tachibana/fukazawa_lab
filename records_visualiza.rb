require 'csv'
require 'fileutils'
require 'launchy'

def init
  FileUtils.mkdir_p('convert_csv/intermediates') unless FileTest.exist?('convert_csv/intermediates')
  FileUtils.mkdir_p('convert_csv/visualize') unless FileTest.exist?('convert_csv/intermediates')
  FileUtils.mkdir_p('convert_csv/compare') unless FileTest.exist?('convert_csv/intermediates')
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

def return_attr_val_arr(line)
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
  [attr, val]
end

# ===================== 以下visualizeに関するメソッド =====================

def write_csv_for_visualize(dir_path, file_name, obj_lines)
  # 属性と値がセットになっているファイルを読み込む
  File.open('convert_csv/intermediates/text_to_attr.txt', 'r') do |f_tta|
    # 書き込み様のCSVファイルを開く
    FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)
    CSV.open("#{dir_path}/#{file_name}", 'w') do |f_atc|
      f_tta.each_line do |line|
        # 現在の行が各オブジェクトの頭から何行目かを算出
        offset = f_tta.lineno % obj_lines
        # 各行の先頭と末尾の余計な文字を削除
        line = line.slice(1..line.length - 3)
        # 各オブジェクトの下から4or2番目だったら("created_at", "updated_at"という文字列しかない)
        if offset == obj_lines - 3 || offset == obj_lines - 1
          # lineを=>で分割し、左側の文字列の””を取り除いてattrに格納
          attr = line.split('=>')[0].gsub(/"/, '')
          # 次の行を読み込み、先頭と末尾の余計な文字を削除してvalに格納
          n_line = f_tta.gets
          val = n_line.slice(1..n_line.length - 3)
          f_atc << [attr, val]
        # その他の行だったら(属性と値がセットで一行に書かれている)
        else
          f_atc << return_attr_val_arr(line)
        end
      end
    end
  end
end

def attr_to_csv_for_visualize(objects)
  # 書き込み様のファイル名を作成
  class_name = objects.first.class.to_s.split('(')[0]
  dir_path = "convert_csv/visualize/#{Time.now.strftime('%y年%m月%d日')}"
  file_name = "#{class_name}#{Time.now.strftime('_%H時%M分%S秒')}.csv"
  # text_to_attr.txtにてオブジェクトごとの行数を算出
  obj_lines = objects.first.attributes.length + 2
  # csvファイルの作成・書き込み
  write_csv_for_visualize(dir_path, file_name, obj_lines)
  "#{dir_path}/#{file_name}"
end

def convert_csv_for_visualize(objects)
  init
  obj_to_text(objects)
  text_to_attr
  attr_to_csv_for_visualize(objects)
end

def csv_to_hash(file_path, attr_num)
  records_hash = {}
  CSV.open(file_path, 'r') do |csv|
    csv.each_slice(attr_num).each_with_index do |rec, rec_id|
      record_hash = {}
      rec.each.with_index do |data, data_id|
        data_hash = {}
        data_hash.store(data[0], data[1])
        record_hash.store(data_id, data_hash)
      end
      records_hash.store("record#{rec_id}", record_hash)
    end
  end
  records_hash
end

def visualize(objects)
  file_path = convert_csv_for_visualize(objects)
  class_name = objects.first.class.to_s.split('(')[0]
  attr_num = objects.first.attributes.length
  records_hash = csv_to_hash(file_path, attr_num)
  Launchy.open("http://localhost:3000//visualize?class_name=#{class_name}&#{records_hash.to_query('records')}")
  # Launchy.open("https://records-visualiza.herokuapp.com/visualize?class_name=#{class_name}&#{records_hash.to_query('records')}")
end

# ===================== 以上visualizeに関するメソッド =====================

# ===================== 以下compareに関するメソッド =====================

module FILETYPE
  SOURCE = 0
  DESTINY = 1
end

def write_csv_for_comp(dir_path, file_name, obj_lines)
  # 属性と値がセットになっているファイルを読み込む
  File.open('convert_csv/intermediates/text_to_attr.txt', 'r') do |f_tta|
    # 書き込み様のCSVファイルを開く
    FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)
    CSV.open("#{dir_path}/#{file_name}", 'w') do |f_atc|
      f_tta.each_line do |line|
        # 現在の行が各オブジェクトの頭から何行目かを算出
        offset = f_tta.lineno % obj_lines
        # 各行の先頭と末尾の余計な文字を削除
        line = line.slice(1..line.length - 3)
        # 各オブジェクトの下から4or2番目だったら("created_at", "updated_at"という文字列しかない)
        if offset == obj_lines - 3 || offset == obj_lines - 1
          # lineを=>で分割し、左側の文字列の””を取り除いてattrに格納
          attr = line.split('=>')[0].gsub(/"/, '')
          # 次の行を読み込み、先頭と末尾の余計な文字を削除してvalに格納
          n_line = f_tta.gets
          val = n_line.slice(1..n_line.length - 3)
          f_atc << [attr, val]
        # その他の行だったら(属性と値がセットで一行に書かれている)
        else
          f_atc << return_attr_val_arr(line)
        end
      end
    end
  end
end

def attr_to_csv_for_comp(objects, file_type)
  # 書き込み様のファイル名を作成
  class_name = objects.first.class.to_s.split('(')[0]
  dir_path = "convert_csv/compare/#{Time.now.strftime('%y年%m月%d日')}/#{Time.now.strftime('%H時%M分%S秒')}"
  file_name = case file_type
              when FILETYPE::SOURCE
                "#{class_name}_source.csv"
              when FILETYPE::DESTINY
                "#{class_name}_destiny.csv"
              end
  # text_to_attr.txtにてオブジェクトごとの行数を算出
  obj_lines = objects.first.attributes.length + 2
  # csvファイルの作成・書き込み
  write_csv_for_comp(dir_path, file_name, obj_lines)
  "#{dir_path}/#{file_name}"
end

def convert_csv_for_comp(objects, file_type)
  init
  obj_to_text(objects)
  text_to_attr
  attr_to_csv_for_comp(objects, file_type)
end

def compare(objects1, objects2)
  file_path1 = convert_csv_for_comp(objects1, FILETYPE::SOURCE)
  file_path2 = convert_csv_for_comp(objects2, FILETYPE::DESTINY)
  class_name = objects1.first.class.to_s.split('(')[0]
  attr_num1 = objects1.first.attributes.length
  attr_num2 = objects2.first.attributes.length
  records_hash1 = csv_to_hash(file_path1, attr_num1)
  records_hash2 = csv_to_hash(file_path2, attr_num2)
  Launchy.open("http://localhost:3000//compare?class_name=#{class_name}&#{records_hash1.to_query('records1')}&#{records_hash2.to_query('records2')}")
end

# ===================== 以上compareに関するメソッド =====================
