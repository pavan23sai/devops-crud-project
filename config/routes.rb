# Define all application routes.
Rails.application.routes.draw do

  # Health-check endpoint used by Docker and Kubernetes.
  get "up" => "rails/health#show", as: :rails_health_check

  # Task Manager CRUD API endpoints.
  get    "/tasks",     to: "tasks#index"
  post   "/tasks",     to: "tasks#create"
  put    "/tasks/:id", to: "tasks#update"
  delete "/tasks/:id", to: "tasks#destroy"
# Display the Task Manager dashboard at the website homepage.
root "home#index"
end