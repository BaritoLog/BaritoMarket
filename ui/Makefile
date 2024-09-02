export .env
EXEC := docker compose exec -it barito-market-ui

dev:
	@docker compose up --build
lint:
	@$(EXEC) npm run lint
build:
	@$(EXEC) npm run build
containerize:
	@docker build -t barito-market-ui:dev --target=final-image .
