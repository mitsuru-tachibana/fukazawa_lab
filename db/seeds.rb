# usersテーブルのレコードを作成
puts("CREATE USERS")
10.times { |i|
  bio = "こんにちは。user_#{i+1}です。趣味は"
  case i % 5
  when 0
    bio << "サッカーです。"
  when 1
    bio << "野球です。"
  when 2
    bio << "バスケです。"
  when 3
    bio << "料理です。"
  when 4
    bio << "読書です。"
  end
  User.create!(
    email: "user_#{i+1}sample.com",
    pass: "pass_#{i+1}",
    name: "user_#{i+1}",
    bio: bio
  )
}
# usersテーブルのレコードを確認
# users = User.all
# users.each { |user|
#   puts(user.inspect)
# }

# relationテーブルのレコードを確認
puts("CREATE RELASHONSHIPS")
users.each { |user|
  followings = users[user.id..9]
  followings.each { |followed|
    user.follow(followed)
  }
}

# usersテーブルのレコードを確認
puts("CREATE POSTS")
users.each { |user|
  10.times { |i|
    user.posts.create!(
      content: "投稿#{i+1}"
    )
  }
}
# postsテーブルのレコードを確認
posts = Post.all
posts.each { |post|
  print(post.inspect)
}

puts("CREATE COMMENTS")
posts.each { |post|
  com_num = rand(0..3)
  com_num.times { |i|
    user_id = rand(1..9)
    user = users.find(user_id)
    post.comments.create!(
      content: "コメント#{i+1}",
      user_id: user_id
    )
  }
}
# commentsテーブルのレコードを確認
comments = Comment.all
comments.each { |comment|
  # puts(comment.inspect)
}

# ractionテーブルのレコードを作成
puts("CREATE REACTIONS")
posts.each { |post|
  react_num = rand(1..10)
  reactors = users.sample(react_num)
  reactors.each { |reactor|
    post.reactions.create!(
      reaction_type: rand(0..2),
      user_id: reactor.id
    )
  }
}
