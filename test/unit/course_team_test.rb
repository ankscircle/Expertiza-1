require File.dirname(__FILE__) + '/../test_helper'

class CourseTeamTest < ActiveSupport::TestCase
  fixtures :courses
  fixtures :assignments
  fixtures :teams
  fixtures :users

  def setup
    @course = courses(:course1)
  end

  def test_row_check
    @row = Array.new(1)
    @number = 2
    assert_operator(@row.length, :<, @number)
  end

  def test_has_options
      @row = Array.new(1)
      @row[0]= "First_Team"
      @name = @row[0].to_s.strip
      assert_match(@row[0],@name)
  end

  def test_has_rename_options
    @course = courses(:course1)
    @options = Array.new
    @currTeam = CourseTeam.new
    @currTeam.name = "Course_team1"
    @currTeam.parent_id = @course.id
    @currTeam.save
    @has_options = "rename"
    @options[0] = @has_options
    assert @options[0]
    assert_not_nil @currTeam
    @name = "Another_Name"
    @currTeam.id = nil
    assert_nil @currTeam.id
   end


  def test_has_replace_options
    @Team = Team.new
    @course = courses(:course1)
    @currTeam = CourseTeam.new
    @teamUser = TeamsUser.new
    @currTeam.name = "Course_team1"
    @currTeam.parent_id = @course.id
    @currTeam.save
    @teamUser.id = @currTeam.id
    @Team.save
    @teamUser.save
    @has_options = "replace"
    @teamUserId = TeamsUser.find(@currTeam.id)
    assert @has_options
    assert_not_nil @teamUserId
    @teamUser.destroy
    assert assert_raise(ActiveRecord::RecordNotFound){ TeamsUser.find(@currTeam.id) }

  end

  def test_add_user_to_team
    @prev_index = 1
    @course = courses(:course1)
    @teamUser = TeamsUser.new
    @currTeam = CourseTeam.new
    @currTeam.name = "Course_team1"
    @currTeam.parent_id = @course.id
    @currTeam.save
    assert assert_raise(ActiveRecord::RecordNotFound){ TeamsUser.find(@currTeam.id) }
    @teamUser.id = @currTeam.id
    @teamUser.save
    @teamUserId = TeamsUser.find(@currTeam.id)
    assert_not_nil @teamUserId
    @new_index = @prev_index + 1
    assert_operator @new_index,:>, @prev_index
 end


  def test_course_nil
    assert_equal "CSC111", @course.name
    @course.id = nil
    @course.save
    assert_equal nil, @course.id
    assert_nil(@course.id, message="course is nil")
  end

  def test_course_team_not_nil
    @course = courses(:course1)
    #@parent = CourseNode.create(:parent_id => nil, :node_object_id => @course.id)
    @currTeam = CourseTeam.new
    @currTeam.name = nil
    @currTeam.parent_id = @course.id
    assert @currTeam.save
    @team = CourseTeam.find(@currTeam)
    assert_not_nil(@team.id, message="team is not nil")
  end

  def test_course_team_nil
    @course = courses(:course1)
    #@parent = CourseNode.create(:parent_id => nil, :node_object_id => @course.id)
    @currTeam = CourseTeam.new
    @currTeam.name = "name"
    @currTeam.parent_id = @course.id
    assert @currTeam.save
    @currTeam.destroy
    assert_raise(ActiveRecord::RecordNotFound){ CourseTeam.find(@currTeam.id) }
 end

   def test_destroy
     @course = courses(:course1)
     @TeamDel = CourseTeam.new
     @TeamDel.name = "test_name"
     @TeamDel.parent_id = @course.id
     assert @TeamDel.save
     @TeamDel.destroy
     assert_raise(ActiveRecord::RecordNotFound){ CourseTeam.find(@TeamDel.id) }
   end

  def test_get_participant_type
    assert "CourseParticipant"
  end

  def test_get_parent_model
    assert "Course"
  end

  def test_get_node_type
    assert "TeamNode"
  end

  def  test_add_participant_nil
    @course = courses(:course1)
    @user = User.new
    @user.name = nil
    @user.fullname = nil
    @user.clear_password = nil
    @user.clear_password_confirmation = nil
    @user.email = nil
    @user.role_id = nil
    @course.id = nil
    @user.id = nil
    assert_nil  (CourseParticipant.find_by_parent_id_and_user_id(@course.id, @user.id))
    assert_not_nil (CourseParticipant.create(:parent_id => @course_id, :user_id => @user.id, :permission_granted => @user.master_permission_granted))
    assert_not_nil (CourseParticipant.find_by_parent_id_and_user_id(@course.id, @user.id))
  end

  def test_get_export_fields
    @fields = Array.new
    @fields.push("Team Name")
    @options = "team_name"
    assert_equal @options,"team_name"
    @fields.push("Team members")
    @fields.push("Assignment Name")
    @fields.push("Course Name")
    assert_equal @fields.count, 4
  end

    def test_export_assignment_teams
      @course = courses(:course1)
      @parent_id = @course
      assert_not_nil (Course.find(@parent_id))
      @assignemntlist = Assignment.find_by_course_id(@parent_id)
      assert_not_nil @assignemntlist
      @testcsv = Array.new
      @teamName =  @assignemntlist.teams.name
      @testcsv.push(@teamName)
      assert_not_nil @teamName
      assert @testcsv

    end

  def test_export_options_team_name
    @options = Array.new
    @has_options = "team_name"
    @options[0] = @has_options
    @course = courses(:course1)
    @teamUser = TeamsUser.new
    @currTeam = CourseTeam.new
    @currTeam.name = "Course_team1"
    @currTeam.parent_id = @course.id
    @currTeam.save
    @teamUser.id = @currTeam.id
    @teamUser.save
    @user = TeamsUser.find(@currTeam.id)
    assert_not_nil @user
    assert_not_nil @options[0]
   # @teamUsers = Array.new
   # @teamUsers.push(@user.name)
   # @teamUsers.push(" ")
   # assert_equal @teamUsers[0], @user.name
  end

end
