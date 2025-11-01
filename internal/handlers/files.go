package handlers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/shri771/gdrive/internal/database"
	"github.com/shri771/gdrive/internal/middleware"
	"github.com/shri771/gdrive/internal/services"
)

type FilesHandler struct {
	queries        *database.Queries
	storageService *services.StorageService
}

func NewFilesHandler(queries *database.Queries, storageService *services.StorageService) *FilesHandler {
	return &FilesHandler{
		queries:        queries,
		storageService: storageService,
	}
}

// UploadFile handles file uploads
func (h *FilesHandler) UploadFile(w http.ResponseWriter, r *http.Request) {
	// Get user from context
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	// Parse multipart form (max 500MB)
	if err := r.ParseMultipartForm(500 << 20); err != nil {
		http.Error(w, "failed to parse form", http.StatusBadRequest)
		return
	}

	// Get file from form
	file, header, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "no file provided", http.StatusBadRequest)
		return
	}
	defer file.Close()

	// Get folder ID (optional)
	folderIDStr := r.FormValue("folder_id")
	var folderID pgtype.UUID
	if folderIDStr != "" {
		parsedUUID, err := uuid.Parse(folderIDStr)
		if err != nil {
			http.Error(w, "invalid folder_id", http.StatusBadRequest)
			return
		}
		folderID = pgtype.UUID{Bytes: parsedUUID, Valid: true}
	}

	// Generate file ID
	fileID := uuid.New()

	// Save file to storage
	storagePath, err := h.storageService.SaveFile(
		uuid.UUID(session.UserID.Bytes),
		fileID,
		file,
		header.Filename,
		1, // version 1
	)
	if err != nil {
		http.Error(w, fmt.Sprintf("failed to save file: %v", err), http.StatusInternalServerError)
		return
	}

	// Determine if preview is available (simple check)
	previewAvailable := false
	mimeType := header.Header.Get("Content-Type")
	if mimeType == "application/pdf" || (len(mimeType) >= 6 && mimeType[:6] == "image/") {
		previewAvailable = true
	}

	// Create file record in database
	dbFile, err := h.queries.CreateFile(r.Context(), database.CreateFileParams{
		Name:             header.Filename,
		OriginalName:     header.Filename,
		MimeType:         mimeType,
		Size:             header.Size,
		StoragePath:      storagePath,
		OwnerID:          session.UserID,
		ParentFolderID:   folderID,
		PreviewAvailable: pgtype.Bool{Bool: previewAvailable, Valid: true},
	})
	if err != nil {
		// Cleanup: delete the uploaded file
		h.storageService.DeleteFile(storagePath)
		http.Error(w, "failed to create file record", http.StatusInternalServerError)
		return
	}

	// Update user storage
	if err := h.queries.UpdateUserStorage(r.Context(), database.UpdateUserStorageParams{
		ID:          session.UserID,
		StorageUsed: pgtype.Int8{Int64: header.Size, Valid: true},
	}); err != nil {
		// Log error but don't fail the request
		fmt.Printf("failed to update storage: %v\n", err)
	}

	// Log activity
	h.queries.LogActivity(r.Context(), database.LogActivityParams{
		UserID:       session.UserID,
		FileID:       dbFile.ID,
		ActivityType: database.ActivityTypeUpload,
	})

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(dbFile)
}

// GetFiles returns files in a folder or root files
func (h *FilesHandler) GetFiles(w http.ResponseWriter, r *http.Request) {
	_, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	folderIDStr := r.URL.Query().Get("folder_id")

	var files []database.File
	var err error

	if folderIDStr == "" {
		// Get root files (files with no parent folder)
		files, err = h.queries.GetFilesByFolder(r.Context(), pgtype.UUID{Valid: false})
	} else {
		folderID, err := uuid.Parse(folderIDStr)
		if err != nil {
			http.Error(w, "invalid folder_id", http.StatusBadRequest)
			return
		}
		files, err = h.queries.GetFilesByFolder(r.Context(), pgtype.UUID{Bytes: folderID, Valid: true})
	}

	if err != nil {
		http.Error(w, "failed to get files", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(files)
}

// GetRecentFiles returns recently accessed files
func (h *FilesHandler) GetRecentFiles(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	files, err := h.queries.GetRecentFiles(r.Context(), database.GetRecentFilesParams{
		OwnerID: session.UserID,
		Limit:   20,
	})
	if err != nil {
		http.Error(w, "failed to get recent files", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(files)
}

// GetStarredFiles returns starred files
func (h *FilesHandler) GetStarredFiles(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	files, err := h.queries.GetStarredFiles(r.Context(), session.UserID)
	if err != nil {
		http.Error(w, "failed to get starred files", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(files)
}

// GetTrashedFiles returns trashed files
func (h *FilesHandler) GetTrashedFiles(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	files, err := h.queries.GetTrashedFiles(r.Context(), session.UserID)
	if err != nil {
		http.Error(w, "failed to get trashed files", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(files)
}

// DownloadFile streams a file for download
func (h *FilesHandler) DownloadFile(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	fileIDStr := chi.URLParam(r, "id")
	fileID, err := uuid.Parse(fileIDStr)
	if err != nil {
		http.Error(w, "invalid file ID", http.StatusBadRequest)
		return
	}

	// Get file from database
	dbFile, err := h.queries.GetFileByID(r.Context(), pgtype.UUID{Bytes: fileID, Valid: true})
	if err != nil {
		http.Error(w, "file not found", http.StatusNotFound)
		return
	}

	// Check ownership
	if dbFile.OwnerID != session.UserID {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	// Open file from storage
	file, err := h.storageService.GetFile(dbFile.StoragePath)
	if err != nil {
		http.Error(w, "failed to open file", http.StatusInternalServerError)
		return
	}
	defer file.Close()

	// Update last accessed
	h.queries.UpdateLastAccessed(r.Context(), pgtype.UUID{Bytes: fileID, Valid: true})

	// Set headers for download
	w.Header().Set("Content-Type", dbFile.MimeType)
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s\"", dbFile.Name))
	w.Header().Set("Content-Length", strconv.FormatInt(dbFile.Size, 10))

	// Stream file
	io.Copy(w, file)
}

// DeleteFile moves a file to trash
func (h *FilesHandler) DeleteFile(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	fileIDStr := chi.URLParam(r, "id")
	fileID, err := uuid.Parse(fileIDStr)
	if err != nil {
		http.Error(w, "invalid file ID", http.StatusBadRequest)
		return
	}

	// Get file to check ownership
	dbFile, err := h.queries.GetFileByID(r.Context(), pgtype.UUID{Bytes: fileID, Valid: true})
	if err != nil {
		http.Error(w, "file not found", http.StatusNotFound)
		return
	}

	if dbFile.OwnerID != session.UserID {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	// Move to trash
	if err := h.queries.TrashFile(r.Context(), pgtype.UUID{Bytes: fileID, Valid: true}); err != nil {
		http.Error(w, "failed to delete file", http.StatusInternalServerError)
		return
	}

	// Log activity
	h.queries.LogActivity(r.Context(), database.LogActivityParams{
		UserID:       session.UserID,
		FileID:       pgtype.UUID{Bytes: fileID, Valid: true},
		ActivityType: database.ActivityTypeDelete,
	})

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "file moved to trash",
	})
}

// RestoreFile restores a file from trash
func (h *FilesHandler) RestoreFile(w http.ResponseWriter, r *http.Request) {
	session, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	fileIDStr := chi.URLParam(r, "id")
	fileID, err := uuid.Parse(fileIDStr)
	if err != nil {
		http.Error(w, "invalid file ID", http.StatusBadRequest)
		return
	}

	// Restore file
	if err := h.queries.RestoreFile(r.Context(), pgtype.UUID{Bytes: fileID, Valid: true}); err != nil {
		http.Error(w, "failed to restore file", http.StatusInternalServerError)
		return
	}

	// Log activity
	h.queries.LogActivity(r.Context(), database.LogActivityParams{
		UserID:       session.UserID,
		FileID:       pgtype.UUID{Bytes: fileID, Valid: true},
		ActivityType: database.ActivityTypeRestore,
	})

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "file restored",
	})
}

// ToggleStar toggles the starred status of a file
func (h *FilesHandler) ToggleStar(w http.ResponseWriter, r *http.Request) {
	_, ok := middleware.GetUserFromContext(r.Context())
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	fileIDStr := chi.URLParam(r, "id")
	fileID, err := uuid.Parse(fileIDStr)
	if err != nil {
		http.Error(w, "invalid file ID", http.StatusBadRequest)
		return
	}

	// Toggle star
	if err := h.queries.ToggleStarFile(r.Context(), pgtype.UUID{Bytes: fileID, Valid: true}); err != nil {
		http.Error(w, "failed to toggle star", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{
		"message": "star toggled",
	})
}

// SearchFiles searches files by name
func (h *FilesHandler) SearchFiles(w http.ResponseWriter, r *http.Request) {
	session, _ := middleware.GetUserFromContext(r.Context())

	query := r.URL.Query().Get("q")
	if query == "" {
		http.Error(w, "search query required", http.StatusBadRequest)
		return
	}

	files, err := h.queries.SearchFilesByName(r.Context(), database.SearchFilesByNameParams{
		OwnerID:        session.UserID,
		PlaintoTsquery: query,
		Limit:          50,
	})
	if err != nil {
		http.Error(w, "failed to search files", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(files)
}
