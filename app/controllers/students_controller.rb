class StudentsController < ApplicationController
  def index
    @all_student = User.where(:owner_type => "Student")
    if params[:sort] || session[:sort] != nil
      sort = params[:sort] || session[:sort]
      case sort
      when 'first_name'
         @all_student = @all_student.order(:first_name)
      when 'last_name'
         @all_student = @all_student.order(:last_name)
      when 'course'
         @all_student = @all_student.order(:placements)
      end
    end
=begin
    if params[:search] || session[:search] != nil
      search = params[:search] || session[:search]
      search_condition = "%" + search + "%"
      @all_student = @all_student.find(:all, :conditions => ['name LIKE ?', search_condition])
    end
=end   
  end
  def placements
    @placements = Student.find(params[:id]).placements
  end
end

