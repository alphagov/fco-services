FCOServices::Application.routes.draw do
  constraints(Transaction) do
    get "/" => "epdq_transactions#start", :as => :transaction
    post "/confirm" => "epdq_transactions#confirm", :format => false, :as => :transaction_confirm
    get "/confirm" => redirect("/"), :format => false
    get "/done" => "epdq_transactions#done", :format => false, :as => :transaction_done
  end

  root :to => redirect("https://www.gov.uk/", :status => 302)
end
