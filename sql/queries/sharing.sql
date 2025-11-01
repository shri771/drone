-- name: CreateFilePermission :one
INSERT INTO file_permissions (file_id, user_id, role, granted_by)
VALUES ($1, $2, $3, $4)
ON CONFLICT (file_id, user_id)
DO UPDATE SET role = EXCLUDED.role
RETURNING *;

-- name: GetFilePermissions :many
SELECT fp.*, u.email, u.name as user_name
FROM file_permissions fp
JOIN users u ON fp.user_id = u.id
WHERE fp.file_id = $1;

-- name: GetUserPermissionForFile :one
SELECT * FROM file_permissions
WHERE file_id = $1 AND user_id = $2;

-- name: RevokePermission :exec
DELETE FROM file_permissions
WHERE file_id = $1 AND user_id = $2;

-- name: GetSharedWithMeFiles :many
SELECT f.*, u.name as owner_name, fp.role
FROM files f
JOIN file_permissions fp ON f.id = fp.file_id
JOIN users u ON f.owner_id = u.id
WHERE fp.user_id = $1 AND f.status = 'active';

-- name: CreateShareLink :one
INSERT INTO share_links (file_id, token, created_by, permission, expires_at)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- name: GetShareLinkByToken :one
SELECT * FROM share_links WHERE token = $1 AND is_active = TRUE;

-- name: DeactivateShareLink :exec
UPDATE share_links SET is_active = FALSE WHERE id = $1;

-- name: GetShareLinksByFile :many
SELECT * FROM share_links WHERE file_id = $1 AND is_active = TRUE;
