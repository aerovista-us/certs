# EchoVerse Music Catalog - API Reference

Complete API documentation for the EchoVerse Music Catalog system, including all endpoints, data structures, and usage examples.

## 📋 Table of Contents

- [Authentication](#authentication)
- [Base URL](#base-url)
- [Core Endpoints](#core-endpoints)
- [Data Endpoints](#data-endpoints)
- [ID System Endpoints](#id-system-endpoints)
- [Work Order Endpoints](#work-order-endpoints)
- [File Serving Endpoints](#file-serving-endpoints)
- [Error Handling](#error-handling)
- [Data Models](#data-models)
- [Examples](#examples)

## 🔐 Authentication

Currently, no authentication is required as the system runs locally. All endpoints are accessible without credentials.

## 🌐 Base URL

```
http://localhost:8000
```

## 🏠 Core Endpoints

### GET /
**Main Dashboard**
- **Description**: Serves the main catalog interface
- **Method**: GET
- **URL**: `/`
- **Response**: HTML page (dashboard.html template)
- **Content-Type**: `text/html`

**Example:**
```bash
curl http://localhost:8000/
```

### GET /gallery
**Album Art Gallery**
- **Description**: Serves the dedicated album art gallery page
- **Method**: GET
- **URL**: `/gallery`
- **Response**: HTML page (gallery.html template)
- **Content-Type**: `text/html`

**Example:**
```bash
curl http://localhost:8000/gallery
```

### GET /health
**Health Check**
- **Description**: Returns server health status
- **Method**: GET
- **URL**: `/health`
- **Response**: JSON with server status
- **Content-Type**: `application/json`

**Response Format:**
```json
{
  "status": "healthy",
  "timestamp": "2025-09-02T10:00:00Z",
  "version": "1.0.0"
}
```

**Example:**
```bash
curl http://localhost:8000/health
```

## 📊 Data Endpoints

### GET /api/catalog
**Full Music Catalog**
- **Description**: Returns the complete music catalog with all tracks
- **Method**: GET
- **URL**: `/api/catalog`
- **Response**: JSON array of track objects
- **Content-Type**: `application/json`

**Response Format:**
```json
[
  {
    "id": "track_a1b2c3_album_x9y8z7_artist_m5n6o7",
    "album_id": "album_x9y8z7_artist_m5n6o7",
    "artist_id": "artist_m5n6o7",
    "album": "Album Name",
    "artist": "Artist Name",
    "track": "Track Title",
    "duration": "3:45",
    "file_size": 12345678,
    "file_path": "M:\\Albums\\Artist\\Album\\track.mp3",
    "cover_file": "M:\\Albums\\Artist\\Album\\cover.jpg",
    "lyrics_file": "",
    "track_number": "01",
    "year": "2025",
    "genre": "Electronic",
    "bitrate": "320",
    "sample_rate": "44100",
    "filename": "track.mp3"
  }
]
```

**Example:**
```bash
curl http://localhost:8000/api/catalog
```

### GET /api/albums
**Albums Grouped by Artist**
- **Description**: Returns albums organized by artist with track counts
- **Method**: GET
- **URL**: `/api/albums`
- **Response**: JSON object with artist-album hierarchy
- **Content-Type**: `application/json`

**Response Format:**
```json
[
  {
    "id": "album_x9y8z7_artist_m5n6o7",
    "album": "Album Name",
    "artist": "Artist Name",
    "artist_id": "artist_m5n6o7",
    "tracks": [
      {
        "id": "track_a1b2c3_album_x9y8z7_artist_m5n6o7",
        "track": "Track Title",
        "duration": "3:45",
        "file_size": 12345678
      }
    ],
    "cover": "M:\\Albums\\Artist\\Album\\cover.jpg",
    "total_duration": 45:30,
    "total_size": 123456789
  }
]
```

**Example:**
```bash
curl http://localhost:8000/api/albums
```

### GET /api/search
**Search Catalog**
- **Description**: Search across all music metadata
- **Method**: GET
- **URL**: `/api/search?q={query}`
- **Parameters**:
  - `q` (string, required): Search query
- **Response**: JSON array of matching tracks
- **Content-Type**: `application/json`

**Example:**
```bash
curl "http://localhost:8000/api/search?q=electronic"
```

## 🆔 ID System Endpoints

### GET /api/track/{track_id}
**Track Details with Relationships**
- **Description**: Returns detailed track information with hierarchical relationships
- **Method**: GET
- **URL**: `/api/track/{track_id}`
- **Parameters**:
  - `track_id` (string, required): Unique track identifier
- **Response**: JSON object with track details and relationships
- **Content-Type**: `application/json`

**Response Format:**
```json
{
  "track": {
    "id": "track_a1b2c3_album_x9y8z7_artist_m5n6o7",
    "album_id": "album_x9y8z7_artist_m5n6o7",
    "artist_id": "artist_m5n6o7",
    "album": "Album Name",
    "artist": "Artist Name",
    "track": "Track Title",
    "duration": "3:45",
    "file_size": 12345678,
    "file_path": "M:\\Albums\\Artist\\Album\\track.mp3",
    "cover_file": "M:\\Albums\\Artist\\Album\\cover.jpg",
    "lyrics_file": "",
    "track_number": "01",
    "year": "2025",
    "genre": "Electronic",
    "bitrate": "320",
    "sample_rate": "44100",
    "filename": "track.mp3"
  },
  "relationships": {
    "trace_path": "track → album → artist",
    "album": {
      "id": "album_x9y8z7_artist_m5n6o7",
      "name": "Album Name",
      "track_count": 12
    },
    "artist": {
      "id": "artist_m5n6o7",
      "name": "Artist Name",
      "album_count": 5
    }
  }
}
```

**Example:**
```bash
curl http://localhost:8000/api/track/track_a1b2c3_album_x9y8z7_artist_m5n6o7
```

### GET /api/album/{album_id}
**Album Details with Relationships**
- **Description**: Returns detailed album information with track list
- **Method**: GET
- **URL**: `/api/album/{album_id}`
- **Parameters**:
  - `album_id` (string, required): Unique album identifier
- **Response**: JSON object with album details and tracks
- **Content-Type**: `application/json`

**Response Format:**
```json
{
  "album": {
    "id": "album_x9y8z7_artist_m5n6o7",
    "name": "Album Name",
    "artist": "Artist Name",
    "artist_id": "artist_m5n6o7",
    "cover": "M:\\Albums\\Artist\\Album\\cover.jpg",
    "total_duration": "45:30",
    "total_size": 123456789,
    "track_count": 12,
    "year": "2025",
    "genre": "Electronic"
  },
  "tracks": [
    {
      "id": "track_a1b2c3_album_x9y8z7_artist_m5n6o7",
      "track": "Track Title",
      "duration": "3:45",
      "file_size": 12345678,
      "track_number": "01"
    }
  ]
}
```

**Example:**
```bash
curl http://localhost:8000/api/album/album_x9y8z7_artist_m5n6o7
```

## 📋 Work Order Endpoints

### GET /api/work-orders
**List All Work Orders**
- **Description**: Returns all created work orders
- **Method**: GET
- **URL**: `/api/work-orders`
- **Response**: JSON array of work order objects
- **Content-Type**: `application/json`

**Response Format:**
```json
[
  {
    "id": "work_order_123",
    "title": "Summer Playlist 2025",
    "type": "playlist",
    "description": "Upbeat tracks for summer vibes",
    "priority": "medium",
    "tracks": [
      {
        "track": "Track Title",
        "album": "Album Name",
        "artist": "Artist Name"
      }
    ],
    "created_at": "2025-09-02T10:00:00Z",
    "status": "active"
  }
]
```

**Example:**
```bash
curl http://localhost:8000/api/work-orders
```

### POST /api/work-orders
**Create New Work Order**
- **Description**: Creates a new work order
- **Method**: POST
- **URL**: `/api/work-orders`
- **Request Body**: JSON object with work order details
- **Response**: JSON object with created work order
- **Content-Type**: `application/json`

**Request Format:**
```json
{
  "title": "New Album Project",
  "type": "album",
  "description": "Creating a new electronic album",
  "priority": "high",
  "tracks": [
    {
      "track": "Track Title",
      "album": "Album Name",
      "artist": "Artist Name"
    }
  ]
}
```

**Response Format:**
```json
{
  "id": "work_order_456",
  "title": "New Album Project",
  "type": "album",
  "description": "Creating a new electronic album",
  "priority": "high",
  "tracks": [
    {
      "track": "Track Title",
      "album": "Album Name",
      "artist": "Artist Name"
    }
  ],
  "created_at": "2025-09-02T10:00:00Z",
  "status": "active"
}
```

**Example:**
```bash
curl -X POST http://localhost:8000/api/work-orders \
  -H "Content-Type: application/json" \
  -d '{
    "title": "New Album Project",
    "type": "album",
    "description": "Creating a new electronic album",
    "priority": "high",
    "tracks": []
  }'
```

### PUT /api/work-orders/{id}
**Update Work Order**
- **Description**: Updates an existing work order
- **Method**: PUT
- **URL**: `/api/work-orders/{id}`
- **Parameters**:
  - `id` (string, required): Work order identifier
- **Request Body**: JSON object with updated work order details
- **Response**: JSON object with updated work order
- **Content-Type**: `application/json`

**Example:**
```bash
curl -X PUT http://localhost:8000/api/work-orders/work_order_456 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Album Project",
    "description": "Updated description",
    "priority": "urgent"
  }'
```

### DELETE /api/work-orders/{id}
**Delete Work Order**
- **Description**: Deletes a work order
- **Method**: DELETE
- **URL**: `/api/work-orders/{id}`
- **Parameters**:
  - `id` (string, required): Work order identifier
- **Response**: JSON object with deletion status
- **Content-Type**: `application/json`

**Response Format:**
```json
{
  "success": true,
  "message": "Work order deleted successfully"
}
```

**Example:**
```bash
curl -X DELETE http://localhost:8000/api/work-orders/work_order_456
```

## 📁 File Serving Endpoints

### GET /api/album-art/{album_name}
**Album Cover Image**
- **Description**: Serves album cover images
- **Method**: GET
- **URL**: `/api/album-art/{album_name}`
- **Parameters**:
  - `album_name` (string, required): URL-encoded album name
- **Response**: Image file (JPEG, PNG, etc.)
- **Content-Type**: Image MIME type

**Example:**
```bash
curl http://localhost:8000/api/album-art/Album%20Name
```

## ❌ Error Handling

### Error Response Format
All endpoints return consistent error responses:

```json
{
  "error": "Error message description",
  "status_code": 400,
  "details": "Additional error details if available"
}
```

### Common HTTP Status Codes
- **200 OK**: Request successful
- **400 Bad Request**: Invalid request parameters
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server-side error

### Error Examples

**404 Not Found:**
```json
{
  "error": "Track not found",
  "status_code": 404,
  "details": "No track found with ID: invalid_id"
}
```

**400 Bad Request:**
```json
{
  "error": "Invalid work order data",
  "status_code": 400,
  "details": "Title is required"
}
```

## 📊 Data Models

### Track Object
```json
{
  "id": "string",           // Unique track identifier
  "album_id": "string",     // Parent album ID
  "artist_id": "string",    // Parent artist ID
  "album": "string",        // Album name
  "artist": "string",       // Artist name
  "track": "string",        // Track title
  "duration": "string",     // Formatted duration (e.g., "3:45")
  "file_size": "number",    // File size in bytes
  "file_path": "string",    // Full file path
  "cover_file": "string",   // Cover image path
  "lyrics_file": "string",  // Lyrics file path
  "track_number": "string", // Track number
  "year": "string",         // Release year
  "genre": "string",        // Music genre
  "bitrate": "string",      // Audio bitrate
  "sample_rate": "string",  // Sample rate
  "filename": "string"      // Original filename
}
```

### Album Object
```json
{
  "id": "string",           // Unique album identifier
  "album": "string",        // Album name
  "artist": "string",       // Artist name
  "artist_id": "string",    // Parent artist ID
  "tracks": "array",        // Array of track objects
  "cover": "string",        // Cover image path
  "total_duration": "string", // Total album duration
  "total_size": "number"    // Total album size in bytes
}
```

### Work Order Object
```json
{
  "id": "string",           // Unique work order identifier
  "title": "string",        // Work order title
  "type": "string",         // Work order type
  "description": "string",  // Work order description
  "priority": "string",     // Priority level
  "tracks": "array",        // Array of track objects
  "created_at": "string",   // Creation timestamp
  "status": "string"        // Current status
}
```

## 💡 Examples

### Complete Workflow Example

**1. Get the catalog:**
```bash
curl http://localhost:8000/api/catalog
```

**2. Search for specific music:**
```bash
curl "http://localhost:8000/api/search?q=electronic"
```

**3. Get track details:**
```bash
curl http://localhost:8000/api/track/track_a1b2c3_album_x9y8z7_artist_m5n6o7
```

**4. Create a work order:**
```bash
curl -X POST http://localhost:8000/api/work-orders \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Electronic Mix",
    "type": "playlist",
    "description": "Collection of electronic tracks",
    "priority": "medium",
    "tracks": []
  }'
```

**5. View all work orders:**
```bash
curl http://localhost:8000/api/work-orders
```

### JavaScript Examples

**Fetch catalog data:**
```javascript
fetch('/api/catalog')
  .then(response => response.json())
  .then(data => {
    console.log('Catalog loaded:', data);
  })
  .catch(error => {
    console.error('Error loading catalog:', error);
  });
```

**Create work order:**
```javascript
const workOrder = {
  title: 'New Project',
  type: 'album',
  description: 'Creating a new album',
  priority: 'high',
  tracks: []
};

fetch('/api/work-orders', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(workOrder)
})
.then(response => response.json())
.then(data => {
  console.log('Work order created:', data);
})
.catch(error => {
  console.error('Error creating work order:', error);
});
```

**Trace track relationships:**
```javascript
fetch('/api/track/track_a1b2c3_album_x9y8z7_artist_m5n6o7')
  .then(response => response.json())
  .then(data => {
    console.log('Track relationships:', data.relationships);
  })
  .catch(error => {
    console.error('Error tracing track:', error);
  });
```

## 🔧 Testing

### Using curl
Test all endpoints from the command line:

```bash
# Health check
curl http://localhost:8000/health

# Get catalog
curl http://localhost:8000/api/catalog

# Search
curl "http://localhost:8000/api/search?q=test"

# Create work order
curl -X POST http://localhost:8000/api/work-orders \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","type":"playlist","description":"Test","priority":"low","tracks":[]}'
```

### Using Browser Dev Tools
Test API endpoints directly in the browser console:

```javascript
// Test health endpoint
fetch('/health').then(r => r.json()).then(console.log);

// Test catalog endpoint
fetch('/api/catalog').then(r => r.json()).then(console.log);
```

## 📝 Notes

- All timestamps are in ISO 8601 format
- File paths use Windows backslash format
- Image serving supports common formats (JPEG, PNG, GIF, WebP)
- The system automatically handles URL encoding for special characters
- All endpoints return JSON except for HTML pages and image files
- Error responses include helpful details for debugging

---

**For more information, see the main README.md file or contact the development team.**
