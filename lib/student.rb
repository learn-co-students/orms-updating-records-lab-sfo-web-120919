require_relative "../config/environment.rb"
require "pry"
class Student
  attr_accessor :name, :grade
  attr_accessor :id

  def initialize(id=nil,name,grade)
    @id = id
    @name = name
    @grade = grade    
  end


  def self.create_table
    sql = <<-SQL 
              CREATE TABLE IF NOT EXISTS students (
              id INTEGER PRIMARY KEY,
              name TEXT,
              grade TEXT
             )
             SQL
    DB[:conn].execute(sql)
  end


  def self.drop_table
    sql = <<-SQL 
              DROP TABLE students
     SQL
     DB[:conn].execute(sql)
  end
 
  # def save
  #   sql = <<-SQL
  #               INSERT INTO students (name,grade) VALUES (?,?)
  #           SQL
  #   DB[:conn].execute(sql,self.name,self.grade)
  #   sql = <<-SQL
  #                         SELECT * FROM students 
  #                     SQL
  #   result = DB[:conn].execute(sql)
  #   # binding.pry
  #   result.each do |ele|
  #     @id = ele[0]
  #     @name = ele[1]
  #     # binding.pry
  #   end
  # end

def save
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end
end
  def self.create(name,grade)
    student1 = Student.new(name,grade)
    student1.save
    student1
  end


  def self.new_from_db(row)
    new_student = self.new(row[1],row[2])
    # binding.pry
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL  
                  SELECT * FROM students WHERE name = ? LIMIT 1
            SQL
    DB[:conn].execute(sql,name).map do |record|
      self.new_from_db(record)
    end.first
  end

  def update()
    sql = <<-SQL 
                  UPDATE students SET name = ? WHERE id = ?
             SQL
    DB[:conn].execute(sql,self.name,self.id)
  end
end
