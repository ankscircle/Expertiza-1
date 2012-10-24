require "test/unit"
require File.dirname(__FILE__) + '/../test_helper'

class InstructorTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @instructor = Instructor.new
    @instructor.name = "testStudent1"
    @instructor.fullname = "test_Student_1"
    @instructor.clear_password = "testStudent1"
    @instructor.clear_password_confirmation = "testStudent1"
    @instructor.email = "testStudent1@foo.edu"
    @instructor.role_id = "1"
    @instructor.save! # an exception is thrown if the instructor is invalid
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    @instructor.destroy
  end

  def test_add_instructor
    instructor = Instructor.find_all_by_name(@instructor.name)
    assert_not_nil(instructor)
  end

  def test_get
    instructor = Instructor.new
    instructor.name = "testStudent1"
    instructor.fullname = "test_Student_1"
    instructor.clear_password = "testStudent1"
    instructor.clear_password_confirmation = "testStudent1"
    instructor.email = "testStudent1@foo.edu"
    instructor.role_id = "1"
    instructor.list_mine(User, instructor.role_id)
    instructor.list_all(User, instructor.role_id)
    instructor.get(User, instructor.id, instructor.role_id)
  end

end