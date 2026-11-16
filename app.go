package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"

	"service-center-go/internal/config"
	"service-center-go/internal/database"
	"service-center-go/internal/models"
	"service-center-go/internal/repository"
)

type App struct {
	ctx         context.Context
	db          *sql.DB
	userRepo    *repository.UserRepository
	currentUser *models.User
}

func NewApp() *App {
	return &App{}
}

func (a *App) startup(ctx context.Context) {
	a.ctx = ctx

	cfg := config.LoadConfig()
	db, err := database.Connect(cfg)
	if err != nil {
		log.Printf("[ВНИМАНИЕ] Не удалось подключиться к БД: %v", err)
		log.Println("[ВНИМАНИЕ] Убедитесь, что Docker-контейнер с PostgreSQL запущен: docker compose up -d")
	} else {
		log.Println("[УСПЕХ] Успешное подключение к PostgreSQL")
		a.db = db
		a.userRepo = repository.NewUserRepository(db)
	}
}

func (a *App) Login(username, password string) models.AuthResponse {
	if a.userRepo == nil {
		return models.AuthResponse{
			Success: false,
			Message: "Нет подключения к базе данных. Проверьте запуск СУБД.",
		}
	}

	user, err := a.userRepo.Authenticate(username, password)
	if err != nil {
		return models.AuthResponse{
			Success: false,
			Message: err.Error(),
		}
	}

	a.currentUser = user
	return models.AuthResponse{
		Success: true,
		Message: fmt.Sprintf("Добро пожаловать, %s!", user.FullName),
		User:    user,
	}
}

func (a *App) Logout() bool {
	a.currentUser = nil
	return true
}

func (a *App) GetCurrentUser() *models.User {
	return a.currentUser
}

func (a *App) ChangePassword(oldPassword, newPassword string) (bool, string) {
	if a.currentUser == nil {
		return false, "Пользователь не авторизован"
	}
	if a.userRepo == nil {
		return false, "Нет подключения к БД"
	}

	err := a.userRepo.ChangePassword(a.currentUser.ID, oldPassword, newPassword)
	if err != nil {
		return false, err.Error()
	}

	return true, "Пароль успешно изменен!"
}
