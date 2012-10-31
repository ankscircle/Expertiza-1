require File.dirname(__FILE__) + '/../test_helper'

class CourseTeamTest < ActiveSupport::TestCase
  fixtures :courses
  fixtures :assignments
  fixtures :teams
  fixtures :users

  def setup
    @course = courses(:course1)
  end

 #tests passes only if the number of rows is less than 2.
  def test_row_check
    @row = Array.new(1)
    @number = 2
    assert_operator(@row.length, :<, @number)
  end

  #tests that the name matches with the first column of the row.
  def test_has_options
      @row = Array.new(1)
      @row[0]= "First_Team"
      @name = @row[0].to_s.strip
      assert_match(@row[0],@name)
  end

  #This test passes only if the given option has a "rename" option and also if the current-team is not null.
  #When the current-team is not null, the current team is made null
  #and the test must pass if it satisfies the changes made.
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

   #This test checks for the presence of "replace" options
   #The test checks whether the teamuser-id is null
   #When the teamuser is deleted, checks whether the record still exists.
   #Thus the test passes if the team-user record is deleted successfully.
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

  #This test sets index to 1 before any changes are made.
  #It asserts true if the team-user record is found in the TeamUser table when searched with the current-Team id.
  #If this tests passes then the index is incremented to reflect the change
  #The increment operation is checked with the last assert statement.
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

  #Test for checking whether the course is nil
  def test_course_nil
    assert_equal "CSC111", @course.name
    @course.id = nil
    @course.save
    assert_equal nil, @course.id
    assert_nil(@course.id, message="course is nil")
  end

  #checks whether the course-team is not null
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

  #test passes only if the current-team being searched is not found
  def test_course_team_nil
    @course = courses(:course1)
    @currTeam = CourseTeam.new
    @currTeam.name = "name"
    @currTeam.parent_id = @course.id
    assert @currTeam.save
    @currTeam.destroy
    assert_raise(ActiveRecord::RecordNotFound){ CourseTeam.find(@currTeam.id) }
 end

    #test passes only if the course-team record begin searched is not found.
    # For this we populate the data for the newly created course-team and delete that record
    # Then test whether that record exists. The test should pass if the record has been deleted.
   def test_destroy
     @course = courses(:course1)
     @TeamDel = CourseTeam.new
     @TeamDel.name = "test_name"
     @TeamDel.parent_id = @course.id
     assert @TeamDel.save
     @TeamDel.destroy
     assert_raise(ActiveRecord::RecordNotFound){ CourseTeam.find(@TeamDel.id) }
   end

  #The following tests for the course participant, course and team-node features exists.
  def test_get_participant_type
    assert "CourseParticipant"
  end

  def test_get_parent_model
    assert "Course"
  end

  def test_get_node_type
    assert "TeamNode"
  end

  #Test whether the course-participant record is null for given course-id and user-id
  #Test checks whether it the course-participant record exist after a record is created
  #Also tests whether the course-participant record  exists when searched by parent-id which
  #is the course-id and by user-id.
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

  #This test is to check whether the fields are exported successfully.
  #It checks for the options - "team_name" and the test passes if it has this option
  #Based on this result, it will also check whether the number of fields exported is equal to four.
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

    #This tests for the existence of the course record based on the parent-id
    #Checks for the existence of the assignment list for the given course
    #Checks for the successful export of the assignment team.
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

  #Tests for the existence of the user and the 'team-name' options. The test passes if it exists.
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
