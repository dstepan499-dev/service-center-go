package database

import (
	"database/sql"
	"fmt"
	"service-center-go/internal/config"
	"time"
)

func Connect(cfg *config.Config) (*sql.DB, error) {
	db, err := sql.Open("pgx", cfg.DSN())
	if err != nil {
		return nil, fmt.Errorf("ошибка открытия дескриптора БД: %w", err)
	}

	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(5 * time.Minute)

	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("база данных недоступна: %w", err)
	}

	return db, nil
}
