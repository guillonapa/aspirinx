class AssignmentsController < ApplicationController
  before_action :logged_in_user
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]

  # GET /assignments
  def index
    @assignments = Assignment.all
  end

  # GET /assignments/1
  def show
    @submission = Submission.where(assignment_id: @assignment.id, user_id: current_user.id).first
    # move code below to user model after has_many and belongs_to are added
    if !@submission
      @submission = Submission.new(user_id: current_user.id, assignment_id: @assignment.id, 
                                   source_code: @assignment.template, submitted: false)
      @submission.save! unless !is_student?
    end
    # need to delete this? in future
    @submissions = nil
  end

  def save
    submission = Submission.find(submission_params[:id])
    submission.update(submission_params)
    flash[:success] = 'Code saved'
    redirect_to submission.assignment
  end

  # GET /assignments/new
  def new
    @assignment = Assignment.new
  end

  # GET /assignments/1/edit
  def edit
    params[:course_id] = @assignment.course.id
  end

  # POST /assignments
  def create
    @assignment = Assignment.new(assignment_params)
    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment.course, :flash => { :success => 'Assignment was successfully created.' } }
        format.json { render :show, status: :created, location: @assignment.course }
      else
        format.html { render :new }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /assignments/1
  def update
    if @assignment.update(assignment_params)
      flash[:success] = "Assignment updated"
      redirect_to edit_assignment_path(@assignment, :course_id => @assignment.course.id)
    else
      render 'edit'
    end
  end

  # DELETE /assignments/1
  def destroy
    course = @assignment.course
    @assignment.destroy
    respond_to do |format|
      format.html { redirect_to course, :flash => { :success => 'Assignment was successfully deleted.' } }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_assignment
      @assignment = Assignment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def assignment_params
      params.require(:assignment).permit(:name, :due_date, :course_id, :instructions, :template)
    end

    def submission_params
      params.require(:submission).permit(:source_code, :assignment_id, :id)
    end
end
