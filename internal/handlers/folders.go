package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/shri771/gdrive/internal/database"
	"github.com/shri771/gdrive/internal/middleware"
)

type FoldersHandler struct {
	queries *database.Queries
}

func NewFoldersHandler(queries *database.Queries) *FoldersHandler {
	return &FoldersHandler{
		queries: queries,
	}
}

type CreateFolderRequest struct {
	Name           string `json:"name"`
	ParentFolderID string `json:"parent_folder_id,omitempty"`
}

// CreateFolder creates a new folder
func (h *FoldersHandler) CreateFolder(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	var req CreateFolderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	if req.Name == "" {
		http.Error(w, "folder name is required", http.StatusBadRequest)
		return
	}

	var parentFolderID pgtype.UUID
	if req.ParentFolderID != "" {
		parsedUUID, err := uuid.Parse(req.ParentFolderID)
		if err != nil {
			http.Error(w, "invalid parent_folder_id", http.StatusBadRequest)
			return
		}
		parentFolderID = pgtype.UUID{Bytes: parsedUUID, Valid: true}
	}

	folder, err := h.queries.CreateFolder(r.Context(), database.CreateFolderParams{
		Name:           req.Name,
		OwnerID:        session.UserID,
		ParentFolderID: parentFolderID,
		IsRoot:         pgtype.Bool{Bool: false, Valid: true},
	})
	if err != nil {
		http.Error(w, "failed to create folder", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(folder)
}

// GetFolders returns subfolders of a folder
func (h *FoldersHandler) GetFolders(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	folderIDStr := r.URL.Query().Get("parent_id")

	var folders []database.Folder
	var err error

	if folderIDStr == "" {
		// Get all folders for user
		folders, err = h.queries.GetFoldersByOwner(r.Context(), session.UserID)
	} else {
		folderID, err := uuid.Parse(folderIDStr)
		if err != nil {
			http.Error(w, "invalid folder_id", http.StatusBadRequest)
			return
		}
		folders, err = h.queries.GetSubfolders(r.Context(), pgtype.UUID{Bytes: folderID, Valid: true})
	}

	if err != nil {
		http.Error(w, "failed to get folders", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(folders)
}

// GetRootFolder returns the user's root folder
func (h *FoldersHandler) GetRootFolder(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	folder, err := h.queries.GetRootFolder(r.Context(), session.UserID)
	if err != nil {
		http.Error(w, "root folder not found", http.StatusNotFound)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(folder)
}
