require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    TaskMailer.stubs(:deliver_task_created)
  end

  def test_relationship_with_requestor
    t = Task.create
    assert_raise ActiveRecord::AssociationTypeMismatch do
      t.requestor = 1
    end
    assert_nothing_raised do
      t.requestor = Person.new
    end
  end

  def test_relationship_with_target
    t = Task.create
    assert_raise ActiveRecord::AssociationTypeMismatch do
      t.target = 1
    end
    assert_nothing_raised do
      t.target = Profile.new
    end
  end

  def test_should_call_perform_in_finish
    TaskMailer.expects(:deliver_task_finished)
    t = Task.create
    t.requestor = sample_user
    t.expects(:perform)
    t.finish
    assert_equal Task::Status::FINISHED, t.status
  end

  def test_should_have_cancelled_status_after_cancel
    TaskMailer.expects(:deliver_task_cancelled)
    t = Task.create
    t.requestor = sample_user
    t.cancel
    assert_equal Task::Status::CANCELLED, t.status
  end

  def test_should_start_with_active_status
    t = Task.create
    assert_equal Task::Status::ACTIVE, t.status
  end

  def test_should_notify_finish
    t = Task.create
    t.requestor = sample_user

    TaskMailer.expects(:deliver_task_finished).with(t)

    t.finish
  end

  def test_should_notify_cancel
    t = Task.create
    t.requestor = sample_user

    TaskMailer.expects(:deliver_task_cancelled).with(t)

    t.cancel
  end

  def test_should_not_notify_when_perform_fails
    count = Task.count

    t = Task.create
    class << t
      def perform
        raise RuntimeError
      end
    end

    t.expects(:notify_requestor).never
    assert_raise RuntimeError do
      t.finish
    end
  end

  should 'provide a description method' do
    assert_kind_of String, Task.new.description
  end

  should 'notify just after the task is created' do
    task = Task.new
    task.requestor = sample_user

    TaskMailer.expects(:deliver_task_created).with(task)
    task.save!
  end

  should 'generate a random code before validation' do
    Task.expects(:generate_code)
    Task.new.valid?
  end

  should 'make sure that codes are unique' do
    task1 = Task.create!
    task2 = Task.new(:code => task1.code)

    assert !task2.valid?
    assert task2.errors.invalid?(:code)
  end

  should 'generate a code with chars from a-z and 0-9' do
    code = Task.generate_code
    assert(code =~ /^[a-z0-9]+$/)
    assert_equal 36, code.size
  end

  should 'find only in active tasks' do
    task = Task.new
    task.requestor = sample_user
    task.save!
    
    task.cancel

    assert_nil Task.find_by_code(task.code)
  end

  should 'be able to find active tasks ' do
    task = Task.new
    task.requestor = sample_user
    task.save!

    assert_not_nil Task.find_by_code(task.code)
  end

  protected

  def sample_user
    User.create(:login => 'testfindinactivetask', :password => 'test', :password_confirmation => 'test', :email => 'testfindinactivetask@localhost.localdomain').person
  end

end
