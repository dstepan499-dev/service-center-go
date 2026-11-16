package repository

import (
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"service-center-go/internal/models"
	"strings"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func HashPassword(password string) string {
	sum := sha256.Sum256([]byte(password))
	return hex.EncodeToString(sum[:])
}

func (r *UserRepository) Authenticate(username, password string) (*models.User, error) {
	username = strings.TrimSpace(username)
	if username == "" || strings.TrimSpace(password) == "" {
		return nil, errors.New("логин и пароль не могут быть пустыми")
	}

	passHash := HashPassword(password)

	query := `
		SELECT id, username, role, full_name, employee_id, is_active, created_at
		FROM app_users
		WHERE username = $1 AND password_hash = $2
	`

	var user models.User
	err := r.db.QueryRow(query, username, passHash).Scan(
		&user.ID,
		&user.Username,
		&user.Role,
		&user.FullName,
		&user.EmployeeID,
		&user.IsActive,
		&user.CreatedAt,
	)

	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return nil, errors.New("неверный логин или пароль")
		}
		return nil, fmt.Errorf("ошибка при выполнении запроса: %w", err)
	}

	if !user.IsActive {
		return nil, errors.New("учетная запись заблокирована администратором")
	}

	return &user, nil
}

func (r *UserRepository) ChangePassword(userID int, oldPassword, newPassword string) error {
	if strings.TrimSpace(newPassword) == "" || len(newPassword) < 6 {
		return errors.New("новый пароль должен содержать минимум 6 символов")
	}

	oldHash := HashPassword(oldPassword)
	newHash := HashPassword(newPassword)

	var exists bool
	checkQuery := `SELECT EXISTS(SELECT 1 FROM app_users WHERE id = $1 AND password_hash = $2)`
	err := r.db.QueryRow(checkQuery, userID, oldHash).Scan(&exists)
	if err != nil || !exists {
		return errors.New("текущий пароль указан неверно")
	}

	updateQuery := `UPDATE app_users SET password_hash = $1 WHERE id = $2`
	_, err = r.db.Exec(updateQuery, newHash, userID)
	if err != nil {
		return fmt.Errorf("не удалось обновить пароль: %w", err)
	}

	return nil
}
