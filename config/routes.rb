Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  post 'voice' => 'webhooks#voice'
  post 'message' => 'webhooks#message'
end
