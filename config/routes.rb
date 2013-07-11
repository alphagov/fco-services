FCOServices::Application.routes.draw do
  constraints(Transaction) do
    get "/start" => "epdq_transactions#start", :format => false, :as => :transaction
    post "/confirm" => "epdq_transactions#confirm", :format => false, :as => :transaction_confirm
    get "/confirm" => redirect("/start"), :format => false
    get "/done" => "epdq_transactions#done", :format => false, :as => :transaction_done
    get "/" => "epdq_transactions#root_redirect"
  end

  root :to => redirect("https://www.gov.uk/", :status => 302)
end
