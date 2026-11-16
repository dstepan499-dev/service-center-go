package models

import (
	"time"
)

type User struct {
	ID         int       `json:"id"`
	Username   string    `json:"username"`
	Role       string    `json:"role"` // director, manager, master, warehouse, admin
	FullName   string    `json:"fullName"`
	EmployeeID *int      `json:"employeeId"`
	IsActive   bool      `json:"isActive"`
	CreatedAt  time.Time `json:"createdAt"`
}

type AuthResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	User    *User  `json:"user,omitempty"`
}
