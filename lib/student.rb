require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_reader :name, :grade, :id

  def initialize(name, grade, id = nil)
    @id = id 
    @name = name 
    @grade = grade 
  end 

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql) 
  end 

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql) 
  end

  def name=(new_name)
    @name = new_name
    save 
  end 
 

  def save 

    if !@id # instance not in db
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?) 
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      set_id_from_db
    else # instance in db, update it
      sql = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = ? 
      SQL
      DB[:conn].execute(sql, self.name, self.grade, self.id)

    end 
    
  end

  def self.create(name, grade)
     new_student = self.new(name, grade)
     new_student.save
  end 

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  
  end 

  def self.find_by_name(possible_name)

    sql = <<-SQL
    SELECT *
    FROM students
    WHERE name = ?
    LIMIT 1 
  SQL

  self.new_from_db(DB[:conn].execute(sql, possible_name)[0])
   
  end 

  def update
    save 
  end 

  
  def set_id_from_db
     

    sql = <<-SQL
      SELECT *
      FROM students
      ORDER BY id DESC
      LIMIT 1 
    SQL

    @id = DB[:conn].execute(sql)[0][0]
    @id 

  end 


end
