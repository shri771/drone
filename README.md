# Team Code Raiders - Google Drive Clone

## Scaler Hackathon Project

A full-stack Google Drive clone with **Go REST API** + **React Frontend** + **PostgreSQL**

---

## 🏗️ Project Status: BACKEND 100% COMPLETE ✅

### ✅ What's Built and Working

**Backend (Go - Port 1030):**
- ✅ PostgreSQL database with 8 tables (Goose migrations)
- ✅ Type-safe SQL queries (sqlc)
- ✅ Complete REST API:
  - Auth: Register, Login, Logout
  - Files: Upload, Download, Delete, Restore, Star, Search
  - Folders: Create, List, Navigate
  - Views: Recent, Starred, Trash
- ✅ File storage service (filesystem with versioning)
- ✅ CORS enabled for React frontend
- ✅ Session-based authentication

**Frontend (React + Vite - Port 5173):**
- ✅ React app scaffolded
- ✅ React Router setup
- ✅ API service layer (Axios)
- ✅ Auth context
- ⚠️ **NEEDS**: UI components (Login, Dashboard, FileList, etc.)

---

## 🚀 Quick Start

### 1. Start Backend
```bash
# From project root
go run cmd/server/main.go
```
**Backend runs on:** http://localhost:1030

### 2. Start Frontend
```bash
cd frontend
npm run dev
```
**Frontend runs on:** http://localhost:5173

---

## 📋 What You Need to Build (Frontend UI Only!)

The backend API is 100% functional! You just need to create React UI components.

### Priority Tasks:

#### 1. **Login Page** (`frontend/src/pages/Login.jsx`)
- Email/password form
- Call `useAuth().login(email, password)`
- Redirect to Dashboard on success

#### 2. **Register Page** (`frontend/src/pages/Register.jsx`)
- Email/password/name form
- Call `useAuth().register(email, password, name)`

#### 3. **Dashboard Page** (`frontend/src/pages/Dashboard.jsx`)
- Sidebar: My Drive, Recent, Starred, Trash links
- File upload area
- File list display
- Call `filesAPI.getFiles()`, `filesAPI.getRecentFiles()`, etc.

#### 4. **FileUpload Component** (`frontend/src/components/FileUpload.jsx`)
- Use `react-dropzone` (already installed)
- Call `filesAPI.uploadFile(file)`

#### 5. **FileList Component** (`frontend/src/components/FileList.jsx`)
- Display files in grid/list
- Actions: Download, Star, Delete
- Use `lucide-react` icons (already installed)

---

## 📖 Complete Component Templates

### Login Page Template
```jsx
// frontend/src/pages/Login.jsx
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await login(email, password);
      navigate('/');
    } catch (err) {
      alert('Login failed');
    }
  };

  return (
    <div style={{ maxWidth: '400px', margin: '100px auto', padding: '20px', border: '1px solid #ccc' }}>
      <h1>Login</h1>
      <form onSubmit={handleSubmit}>
        <input
          type="email"
          placeholder="Email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          style={{ width: '100%', padding: '10px', marginBottom: '10px' }}
        />
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          style={{ width: '100%', padding: '10px', marginBottom: '10px' }}
        />
        <button type="submit" style={{ width: '100%', padding: '10px', background: '#007bff', color: 'white' }}>
          Login
        </button>
      </form>
      <p>Don't have an account? <a href="/register">Register</a></p>
    </div>
  );
}

export default Login;
```

### Dashboard Template
```jsx
// frontend/src/pages/Dashboard.jsx
import { useState, useEffect } from 'react';
import { filesAPI } from '../services/api';
import { useAuth } from '../context/AuthContext';

function Dashboard({ view = 'mydrive' }) {
  const [files, setFiles] = useState([]);
  const { logout } = useAuth();

  useEffect(() => {
    loadFiles();
  }, [view]);

  const loadFiles = async () => {
    try {
      let data;
      if (view === 'recent') data = await filesAPI.getRecentFiles();
      else if (view === 'starred') data = await filesAPI.getStarredFiles();
      else if (view === 'trash') data = await filesAPI.getTrashedFiles();
      else data = await filesAPI.getFiles();
      setFiles(data || []);
    } catch (error) {
      console.error('Failed to load files:', error);
    }
  };

  const handleUpload = async (e) => {
    const file = e.target.files[0];
    if (file) {
      try {
        await filesAPI.uploadFile(file);
        loadFiles();
      } catch (error) {
        alert('Upload failed');
      }
    }
  };

  return (
    <div style={{ display: 'flex', height: '100vh' }}>
      {/* Sidebar */}
      <div style={{ width: '200px', background: '#f5f5f5', padding: '20px' }}>
        <h2>GDrive</h2>
        <nav>
          <div><a href="/">My Drive</a></div>
          <div><a href="/recent">Recent</a></div>
          <div><a href="/starred">Starred</a></div>
          <div><a href="/trash">Trash</a></div>
          <button onClick={logout} style={{ marginTop: '20px' }}>Logout</button>
        </nav>
      </div>

      {/* Main */}
      <div style={{ flex: 1, padding: '20px' }}>
        <input type="file" onChange={handleUpload} />
        <h2>{view === 'mydrive' ? 'My Drive' : view}</h2>
        <div>
          {files.map((file) => (
            <div key={file.id} style={{ border: '1px solid #ccc', padding: '10px', margin: '10px 0' }}>
              <strong>{file.name}</strong> - {(file.size / 1024).toFixed(2)} KB
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default Dashboard;
```

---

## 🔧 All API Endpoints (Backend Ready)

### Auth
- `POST /api/auth/register` - {email, password, name}
- `POST /api/auth/login` - {email, password}
- `POST /api/auth/logout`
- `GET /api/auth/me`

### Files
- `GET /api/files` - List files
- `POST /api/files/upload` - Upload (multipart/form-data)
- `GET /api/files/recent`
- `GET /api/files/starred`
- `GET /api/files/trash`
- `GET /api/files/search?q=query`
- `GET /api/files/{id}/download`
- `DELETE /api/files/{id}`
- `POST /api/files/{id}/restore`
- `POST /api/files/{id}/star`

### Folders
- `GET /api/folders`
- `POST /api/folders` - {name, parent_folder_id}

---

## 📦 Tech Stack

**Backend:**
- Go 1.21+
- Chi (router)
- PostgreSQL 18
- sqlc (type-safe SQL)
- Goose (migrations)
- bcrypt (password hashing)

**Frontend:**
- React 18
- Vite
- React Router
- Axios
- react-dropzone
- lucide-react (icons)

---

## 🎯 Hackathon Demo Flow

1. Register new user
2. Upload files (drag & drop)
3. Download files
4. Star files → show starred view
5. Delete → show trash → restore
6. Search files

---

## ⚡ Commands Cheat Sheet

```bash
# Backend
go run cmd/server/main.go        # Start server (port 1030)
make migrate-up                    # Run database migrations
make sqlc                          # Regenerate Go code from SQL

# Frontend
cd frontend
npm run dev                        # Start dev server (port 5173)
npm run build                      # Build for production

# Database
psql -U postgres gdrive            # Connect to database
make migrate-status                # Check migration status
```

---

## 🏆 Team Code Raiders - Let's win this! 🚀