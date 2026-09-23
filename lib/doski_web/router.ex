defmodule DoskiWeb.Router do
  use DoskiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :auth do
    plug(DoskiWeb.AuthPipeline)
  end

  scope "/api", DoskiWeb do
    pipe_through(:api)

    get("/health", HealthController, :show)
    post("/registrations", RegistrationController, :create)
    post("/sessions", SessionController, :create)
  end

  scope "/api", DoskiWeb do
    pipe_through([:api, :auth])

    get("/me", SessionController, :show)

    get("/boards", BoardController, :index)
    post("/boards", BoardController, :create)
    get("/boards/:id", BoardController, :show)
    patch("/boards/:id", BoardController, :update)
    delete("/boards/:id", BoardController, :delete)

    post("/boards/:board_id/members", MemberController, :create)
    delete("/boards/:board_id/members/:user_id", MemberController, :delete)

    post("/boards/:board_id/lists", ListController, :create)
    patch("/lists/:id", ListController, :update)
    delete("/lists/:id", ListController, :delete)

    post("/lists/:list_id/cards", CardController, :create)
    patch("/cards/:id", CardController, :update)
    delete("/cards/:id", CardController, :delete)
    post("/cards/:id/move", CardController, :move)
  end

  scope "/api", DoskiWeb do
    pipe_through(:api)
    match(:*, "/*path", FallbackController, :not_found)
  end

  scope "/", DoskiWeb do
    get("/", PageController, :index)
    get("/*path", PageController, :index)
  end
end
