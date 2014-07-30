Rails.application.routes.draw do
  post "/db_stores" => "db_stores#create"
  post "/db_stores/restore" => "db_stores#restore"
  post "/db_stores/destroy" => "db_stores#destroy"
end
