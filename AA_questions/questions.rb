require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :id, :fname, :lname

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

      User.new(user.first) # user returns hash in an array
  end

  def self.find_by_name(fname,lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname,lname)
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = ? AND users.lname = ?
    SQL

    User.new(user.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def initialize(options)
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end
end

class Question
  attr_accessor :id, :title, :body, :author_id

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

      Question.new(question.first) # user returns hash in an array
  end

  def self.find_by_author_id(author_id)
    author = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.author_id = ?
    SQL
      author = author.map{|question| Question.new(question)}
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def initialize(options)
    @id = options["id"]
    @title= options["title"]
    @body = options["body"]
    @author_id = options["author_id"]
  end

end

class QuestionFollow
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    follow = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        question_follows.id = ?
    SQL

      QuestionFollow.new(follow.first) # user returns hash in an array
  end

  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end

end

class Reply
  attr_accessor :id, :question_id, :parent_reply, :user_id, :body

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL

      Reply.new(reply.first) # user returns hash in an array
  end

  def self.find_by_user_id(user_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

      replies = replies.map {|reply| Reply.new(reply)}
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL

      replies = replies.map {|reply| Reply.new(reply)}
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Question.find_by_id(@parent_reply)
  end

  def child_replies
    children = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_reply = ?
    SQL

    children = children.map {|reply| Reply.new(reply)}
  end

  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @parent_reply = options["parent_reply"]
    @user_id = options["user_id"]
    @body = options["body"]
  end

end

class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def self.find_by_id(id)
    like = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_likes.id = ?
    SQL

      QuestionLike.new(like.first) # user returns hash in an array
  end

  def initialize(options)
    @id = options["id"]
    @user_id = options["user_id"]
    @question_id = options["question_id"]
  end

end
