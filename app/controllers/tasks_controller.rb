
# Controller responsible for handling Task Manager API requests.
class TasksController < ApplicationController
  # These endpoints accept JSON API requests from external clients.
  # They do not use browser form sessions or CSRF tokens.
  skip_forgery_protection
  # GET /tasks
  # Retrieve all tasks from the database.
  def index
    tasks = Task.order(:id)

    # Return all tasks as JSON.
    render json: tasks
  end

  # POST /tasks
  # Create a new task in the database.
  def create

    # Read the task title from the incoming JSON request.
    title = params[:title]

    # Validate that the title is a non-empty string
    # and does not exceed 200 characters.
    unless valid_title?(title)
      return render json: {
        error: "A task title is required"
      }, status: :bad_request
    end

    # Create the task using the cleaned title.
    task = Task.new(title: title.strip)

    # Save the task and return the result.
    if task.save
      render json: task, status: :created
    else
      render json: {
        error: "A task title is required"
      }, status: :bad_request
    end
  end

  # PUT /tasks/:id
  # Update an existing task.
  def update

    # Validate that the task ID is a positive integer.
    unless valid_task_id?
      return render json: {
        error: "Invalid task ID"
      }, status: :bad_request
    end

    # Find the task using the ID from the URL.
    task = Task.find_by(id: params[:id])

    # Return 404 if the task does not exist.
    unless task
      return render json: {
        error: "Task not found"
      }, status: :not_found
    end

    # Check whether a title was provided.
    if params.key?(:title)
      title = params[:title]

      # Validate the new title.
      unless valid_title?(title)
        return render json: {
          error: "Title must be a non-empty string"
        }, status: :bad_request
      end

      # Update the title after removing extra spaces.
      task.title = title.strip
    end

    # Check whether a completion status was provided.
    if params.key?(:completed)

      # Accept only true or false.
      unless params[:completed] == true || params[:completed] == false
        return render json: {
          error: "Completed must be true or false"
        }, status: :bad_request
      end

      # Update the completion status.
      task.completed = params[:completed]
    end

    # Require at least one field to update.
    unless params.key?(:title) || params.key?(:completed)
      return render json: {
        error: "Provide a title or completed field"
      }, status: :bad_request
    end

    # Save the updated task.
    if task.save
      render json: task
    else
      render json: {
        error: "Unable to update task"
      }, status: :bad_request
    end
  end

  # DELETE /tasks/:id
  # Delete an existing task.
  def destroy

    # Validate that the task ID is a positive integer.
    unless valid_task_id?
      return render json: {
        error: "Invalid task ID"
      }, status: :bad_request
    end

    # Find the task using its ID.
    task = Task.find_by(id: params[:id])

    # Return 404 if the task does not exist.
    unless task
      return render json: {
        error: "Task not found"
      }, status: :not_found
    end

    # Save the ID before deleting the task.
    task_id = task.id

    # Delete the task from the database.
    task.destroy!

    # Return a success message.
    render json: {
      message: "Task #{task_id} deleted successfully"
    }
  end

  private

  # Check whether a title is valid.
  # It must be a non-empty string with at most 200 characters.
  def valid_title?(title)
    title.is_a?(String) &&
      title.strip.present? &&
      title.strip.length <= 200
  end

  # Check whether the supplied task ID is a positive integer.
  def valid_task_id?
    params[:id].to_s.match?(/\A[1-9]\d*\z/)
  end

end
