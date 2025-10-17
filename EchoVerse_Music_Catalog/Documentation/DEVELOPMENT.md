# EchoVerse Music Catalog - Development Guide

Comprehensive development guide for contributors, maintainers, and developers who want to extend, modify, or contribute to the EchoVerse Music Catalog system.

## 📋 Table of Contents

- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Code Standards](#code-standards)
- [Adding Features](#adding-features)
- [Testing](#testing)
- [Debugging](#debugging)
- [Performance Optimization](#performance-optimization)
- [Contributing Guidelines](#contributing-guidelines)
- [Release Process](#release-process)
- [Troubleshooting Development Issues](#troubleshooting-development-issues)

## 🛠️ Development Setup

### Prerequisites
- **Python 3.8+**: Core development language
- **Git**: Version control system
- **VS Code/Cursor**: Recommended IDE with Python extensions
- **Modern Browser**: For frontend testing
- **Windows 10/11**: Primary development platform

### Environment Setup
1. **Clone Repository**: Get the source code
2. **Create Virtual Environment**:
   ```bash
   python -m venv .venv
   .venv\Scripts\activate  # Windows
   ```
3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   pip install -r requirements-dev.txt  # If available
   ```
4. **Install Development Tools**:
   ```bash
   pip install black flake8 pytest mypy
   ```

### Development Dependencies
```bash
# Code formatting and linting
pip install black flake8 isort

# Type checking
pip install mypy

# Testing
pip install pytest pytest-asyncio pytest-cov

# Development server
pip install uvicorn[standard] watchfiles

# Documentation
pip install mkdocs mkdocs-material
```

### IDE Configuration
#### VS Code/Cursor Settings
```json
{
  "python.defaultInterpreterPath": "./.venv/Scripts/python.exe",
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.formatting.provider": "black",
  "python.sortImports.args": ["--profile", "black"],
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  }
}
```

#### Python Path Configuration
Ensure your IDE recognizes the project structure:
- Root directory: `EchoVerse_Music_Catalog/`
- Python path: `./.venv/Scripts/python.exe`
- Working directory: Project root

## 📁 Project Structure

### Core Files
```
EchoVerse_Music_Catalog/
├── main.py                 # FastAPI application entry point
├── requirements.txt        # Production dependencies
├── requirements-dev.txt    # Development dependencies (create this)
├── start_catalog.bat      # Windows startup script
├── .gitignore             # Git ignore patterns
├── pyproject.toml         # Project configuration (create this)
└── README.md             # Project documentation
```

### Template Structure
```
templates/
├── dashboard.html         # Main dashboard template
├── gallery.html           # Album art gallery template
├── base.html             # Base template (create this)
└── components/           # Reusable components (create this)
    ├── header.html       # Navigation header
    ├── footer.html       # Page footer
    └── modals.html       # Modal dialogs
```

### Static Assets
```
static/                   # Static file serving (create this)
├── css/                 # Stylesheets
│   ├── main.css        # Main styles
│   ├── components.css  # Component styles
│   └── themes.css      # Theme variations
├── js/                 # JavaScript files
│   ├── app.js         # Main application logic
│   ├── api.js         # API communication
│   └── utils.js       # Utility functions
└── images/             # Static images
    ├── icons/          # UI icons
    └── logos/          # Brand assets
```

### Configuration Files
```
config/                  # Configuration management (create this)
├── __init__.py         # Configuration module
├── settings.py         # Application settings
├── database.py         # Database configuration
└── logging.py          # Logging configuration
```

## 📝 Code Standards

### Python Standards
- **PEP 8**: Follow Python style guide
- **Type Hints**: Use type annotations for all functions
- **Docstrings**: Comprehensive function documentation
- **Error Handling**: Proper exception handling and logging

#### Code Example
```python
from typing import List, Optional, Dict, Any
import logging

logger = logging.getLogger(__name__)

def process_music_catalog(csv_path: str) -> List[Dict[str, Any]]:
    """
    Process music catalog CSV file and return structured data.
    
    Args:
        csv_path: Path to the CSV inventory file
        
    Returns:
        List of processed music track dictionaries
        
    Raises:
        FileNotFoundError: If CSV file doesn't exist
        ValueError: If CSV format is invalid
    """
    try:
        # Implementation here
        pass
    except FileNotFoundError as e:
        logger.error(f"CSV file not found: {csv_path}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error processing CSV: {e}")
        raise
```

### Frontend Standards
- **HTML5 Semantic**: Use proper semantic elements
- **CSS3 Best Practices**: Modern CSS with proper organization
- **JavaScript ES6+**: Modern JavaScript features
- **Accessibility**: WCAG 2.1 AA compliance

#### HTML Example
```html
<!-- Use semantic HTML5 elements -->
<main class="music-catalog">
  <section class="catalog-header" aria-label="Catalog Overview">
    <h1 class="catalog-title">Music Catalog</h1>
    <div class="catalog-stats" role="region" aria-label="Collection Statistics">
      <!-- Statistics content -->
    </div>
  </section>
  
  <section class="catalog-content" aria-label="Music Collection">
    <!-- Catalog content -->
  </section>
</main>
```

#### CSS Example
```css
/* Use CSS custom properties for theming */
:root {
  --primary-color: #6366f1;
  --secondary-color: #8b5cf6;
  --background-color: #0f172a;
  --text-color: #f8fafc;
  --border-radius: 0.5rem;
  --transition-duration: 0.2s;
}

/* Component-based CSS organization */
.music-catalog {
  background-color: var(--background-color);
  color: var(--text-color);
  border-radius: var(--border-radius);
  transition: all var(--transition-duration) ease;
}

/* Responsive design */
@media (max-width: 768px) {
  .music-catalog {
    padding: 1rem;
  }
}
```

#### JavaScript Example
```javascript
// Use ES6+ features and proper error handling
class MusicCatalog {
  constructor() {
    this.catalog = [];
    this.filters = new Map();
    this.init();
  }

  async init() {
    try {
      await this.loadCatalog();
      this.setupEventListeners();
      this.render();
    } catch (error) {
      console.error('Failed to initialize catalog:', error);
      this.showError('Failed to load music catalog');
    }
  }

  async loadCatalog() {
    const response = await fetch('/api/catalog');
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    this.catalog = await response.json();
  }

  showError(message) {
    // Error display logic
  }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  new MusicCatalog();
});
```

## 🚀 Adding Features

### Backend Features

#### 1. New API Endpoints
```python
from fastapi import APIRouter, HTTPException
from typing import List, Optional
from pydantic import BaseModel

router = APIRouter()

class NewFeatureRequest(BaseModel):
    name: str
    description: Optional[str] = None
    priority: str = "medium"

@router.post("/api/new-feature")
async def create_new_feature(request: NewFeatureRequest):
    """Create a new feature with validation."""
    try:
        # Implementation logic
        result = {"id": "feature_123", "name": request.name}
        return result
    except Exception as e:
        logger.error(f"Failed to create feature: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
```

#### 2. Data Processing Functions
```python
def process_new_data_type(data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """Process new data type with validation and transformation."""
    processed = []
    
    for item in data:
        try:
            # Validation
            if not validate_item(item):
                logger.warning(f"Invalid item skipped: {item}")
                continue
                
            # Transformation
            processed_item = transform_item(item)
            processed.append(processed_item)
            
        except Exception as e:
            logger.error(f"Error processing item {item}: {e}")
            continue
    
    return processed
```

#### 3. Configuration Management
```python
from pydantic import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    """Application settings with environment variable support."""
    app_name: str = "EchoVerse Music Catalog"
    debug: bool = False
    host: str = "0.0.0.0"
    port: int = 8000
    music_paths: List[str] = ["M:\\Albums\\"]
    max_file_size: int = 100 * 1024 * 1024  # 100MB
    
    class Config:
        env_file = ".env"

settings = Settings()
```

### Frontend Features

#### 1. New Components
```html
<!-- templates/components/new-feature.html -->
<div class="new-feature" data-feature-id="{{ feature.id }}">
  <div class="feature-header">
    <h3 class="feature-title">{{ feature.name }}</h3>
    <div class="feature-actions">
      <button class="btn btn-primary" onclick="editFeature('{{ feature.id }}')">
        Edit
      </button>
      <button class="btn btn-danger" onclick="deleteFeature('{{ feature.id }}')">
        Delete
      </button>
    </div>
  </div>
  <div class="feature-content">
    <p class="feature-description">{{ feature.description }}</p>
  </div>
</div>
```

#### 2. JavaScript Modules
```javascript
// static/js/features.js
export class FeatureManager {
  constructor() {
    this.features = new Map();
    this.init();
  }

  async init() {
    await this.loadFeatures();
    this.setupEventListeners();
  }

  async loadFeatures() {
    try {
      const response = await fetch('/api/features');
      const features = await response.json();
      
      features.forEach(feature => {
        this.features.set(feature.id, feature);
      });
      
      this.render();
    } catch (error) {
      console.error('Failed to load features:', error);
    }
  }

  render() {
    const container = document.getElementById('features-container');
    if (!container) return;

    container.innerHTML = '';
    
    this.features.forEach(feature => {
      const element = this.createFeatureElement(feature);
      container.appendChild(element);
    });
  }

  createFeatureElement(feature) {
    const div = document.createElement('div');
    div.className = 'feature-item';
    div.innerHTML = `
      <h4>${feature.name}</h4>
      <p>${feature.description || ''}</p>
    `;
    return div;
  }
}
```

#### 3. CSS Styling
```css
/* static/css/features.css */
.feature-item {
  background: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius);
  padding: 1rem;
  margin-bottom: 1rem;
  transition: all var(--transition-duration) ease;
}

.feature-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.feature-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.feature-title {
  margin: 0;
  color: var(--text-primary);
  font-size: 1.1rem;
  font-weight: 600;
}

.feature-actions {
  display: flex;
  gap: 0.5rem;
}

.btn {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: var(--border-radius);
  cursor: pointer;
  transition: background-color var(--transition-duration) ease;
}

.btn-primary {
  background-color: var(--primary-color);
  color: white;
}

.btn-primary:hover {
  background-color: var(--primary-dark);
}
```

## 🧪 Testing

### Testing Strategy
- **Unit Tests**: Individual function testing
- **Integration Tests**: API endpoint testing
- **Frontend Tests**: Component and UI testing
- **End-to-End Tests**: Complete workflow testing

### Test Setup
```bash
# Install testing dependencies
pip install pytest pytest-asyncio pytest-cov httpx

# Run tests
pytest tests/ -v --cov=main --cov-report=html

# Run specific test file
pytest tests/test_api.py -v

# Run with coverage report
pytest tests/ --cov=main --cov-report=term-missing
```

### Test Examples

#### Backend Tests
```python
# tests/test_api.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_endpoint():
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"

def test_catalog_endpoint():
    """Test catalog endpoint returns data."""
    response = client.get("/api/catalog")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)

@pytest.mark.asyncio
async def test_work_order_creation():
    """Test work order creation."""
    work_order_data = {
        "title": "Test Project",
        "type": "playlist",
        "description": "Test description",
        "priority": "medium",
        "tracks": []
    }
    
    response = client.post("/api/work-orders", json=work_order_data)
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Project"
```

#### Frontend Tests
```javascript
// tests/features.test.js
import { FeatureManager } from '../static/js/features.js';

describe('FeatureManager', () => {
  let featureManager;
  
  beforeEach(() => {
    featureManager = new FeatureManager();
  });
  
  test('should initialize with empty features', () => {
    expect(featureManager.features.size).toBe(0);
  });
  
  test('should load features from API', async () => {
    // Mock fetch
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve([
          { id: '1', name: 'Test Feature' }
        ])
      })
    );
    
    await featureManager.loadFeatures();
    expect(featureManager.features.size).toBe(1);
  });
});
```

### Test Configuration
```python
# pytest.ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    -v
    --strict-markers
    --disable-warnings
    --tb=short
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    unit: marks tests as unit tests
```

## 🐛 Debugging

### Backend Debugging
```python
import logging
import traceback

# Configure detailed logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

def debug_function(data):
    """Function with comprehensive debugging."""
    logger.debug(f"Function called with data: {data}")
    
    try:
        # Your logic here
        result = process_data(data)
        logger.debug(f"Function completed successfully: {result}")
        return result
        
    except Exception as e:
        logger.error(f"Function failed: {e}")
        logger.error(f"Traceback: {traceback.format_exc()}")
        raise
```

### Frontend Debugging
```javascript
// Enable debug mode
const DEBUG = true;

function debugLog(message, data = null) {
  if (DEBUG) {
    console.log(`[DEBUG] ${message}`, data);
  }
}

function debugError(message, error = null) {
  if (DEBUG) {
    console.error(`[ERROR] ${message}`, error);
  }
}

// Use in your code
class MusicCatalog {
  async loadCatalog() {
    debugLog('Loading catalog...');
    
    try {
      const response = await fetch('/api/catalog');
      debugLog('API response received', response);
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      const data = await response.json();
      debugLog('Catalog data loaded', data);
      
      return data;
      
    } catch (error) {
      debugError('Failed to load catalog', error);
      throw error;
    }
  }
}
```

### Browser Debugging
```javascript
// Add debugging to DOM elements
function addDebugInfo(element, data) {
  if (DEBUG) {
    element.setAttribute('data-debug', JSON.stringify(data));
  }
}

// Debug event handlers
function debugEventHandler(event, handlerName) {
  if (DEBUG) {
    console.log(`[EVENT] ${handlerName}`, {
      target: event.target,
      type: event.type,
      data: event.target.dataset
    });
  }
}

// Use in event listeners
button.addEventListener('click', (event) => {
  debugEventHandler(event, 'button-click');
  // Your handler logic
});
```

## ⚡ Performance Optimization

### Backend Optimization
```python
from functools import lru_cache
import asyncio
from concurrent.futures import ThreadPoolExecutor

# Caching expensive operations
@lru_cache(maxsize=128)
def get_album_art_path(album_name: str) -> str:
    """Cache album art path lookups."""
    return find_album_art(album_name)

# Async processing for I/O operations
async def process_multiple_files(file_paths: List[str]) -> List[Dict]:
    """Process multiple files concurrently."""
    executor = ThreadPoolExecutor(max_workers=4)
    
    async def process_file(path: str) -> Dict:
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(executor, process_single_file, path)
    
    tasks = [process_file(path) for path in file_paths]
    return await asyncio.gather(*tasks)

# Efficient data structures
from collections import defaultdict

def group_tracks_efficiently(tracks: List[Dict]) -> Dict:
    """Group tracks using efficient data structures."""
    grouped = defaultdict(list)
    
    for track in tracks:
        artist = track.get('artist', 'Unknown')
        grouped[artist].append(track)
    
    return dict(grouped)
```

### Frontend Optimization
```javascript
// Debounced search
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Optimized search
const debouncedSearch = debounce(async (query) => {
  if (query.length < 2) return;
  
  try {
    const response = await fetch(`/api/search?q=${encodeURIComponent(query)}`);
    const results = await response.json();
    updateSearchResults(results);
  } catch (error) {
    console.error('Search failed:', error);
  }
}, 300);

// Virtual scrolling for large lists
class VirtualList {
  constructor(container, items, itemHeight) {
    this.container = container;
    this.items = items;
    this.itemHeight = itemHeight;
    this.visibleItems = Math.ceil(container.clientHeight / itemHeight);
    this.scrollTop = 0;
    
    this.setupVirtualScrolling();
  }
  
  setupVirtualScrolling() {
    this.container.addEventListener('scroll', () => {
      this.scrollTop = this.container.scrollTop;
      this.renderVisibleItems();
    });
  }
  
  renderVisibleItems() {
    const startIndex = Math.floor(this.scrollTop / this.itemHeight);
    const endIndex = Math.min(startIndex + this.visibleItems, this.items.length);
    
    // Render only visible items
    this.renderItems(startIndex, endIndex);
  }
}
```

## 🤝 Contributing Guidelines

### Pull Request Process
1. **Fork Repository**: Create your own fork
2. **Create Feature Branch**: `git checkout -b feature/amazing-feature`
3. **Make Changes**: Implement your feature
4. **Add Tests**: Include tests for new functionality
5. **Update Documentation**: Update relevant docs
6. **Submit PR**: Create pull request with description

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types**: feat, fix, docs, style, refactor, test, chore
**Examples**:
```
feat(api): add new search endpoint
fix(ui): resolve album art display issue
docs(readme): update installation instructions
```

### Code Review Checklist
- [ ] Code follows style guidelines
- [ ] Tests pass and cover new functionality
- [ ] Documentation is updated
- [ ] No breaking changes introduced
- [ ] Performance impact considered
- [ ] Security implications reviewed

## 🚀 Release Process

### Version Management
```python
# main.py
__version__ = "1.2.0"

# Semantic versioning: MAJOR.MINOR.PATCH
# MAJOR: Breaking changes
# MINOR: New features, backward compatible
# PATCH: Bug fixes, backward compatible
```

### Release Checklist
- [ ] Update version number
- [ ] Update changelog
- [ ] Run full test suite
- [ ] Update documentation
- [ ] Create release tag
- [ ] Deploy to production
- [ ] Announce release

### Changelog Format
```markdown
# Changelog

## [1.2.0] - 2025-09-02

### Added
- New album art gallery feature
- Lazy loading for improved performance
- Unique ID system for relationship tracing

### Changed
- Improved CSV parsing performance
- Enhanced error handling and logging

### Fixed
- Album art display issues
- Memory usage optimization
- Search functionality improvements
```

## 🔧 Troubleshooting Development Issues

### Common Development Problems

#### Import Errors
```bash
# Problem: Module not found
ModuleNotFoundError: No module named 'fastapi'

# Solution: Activate virtual environment
.venv\Scripts\activate  # Windows
source .venv/bin/activate  # Linux/Mac

# Verify installation
pip list | grep fastapi
```

#### Port Conflicts
```bash
# Problem: Port already in use
OSError: [Errno 98] Address already in use

# Solution: Find and kill process
netstat -tlnp | grep :8000
kill -9 <PID>

# Or change port in main.py
uvicorn.run(app, host="0.0.0.0", port=8001)
```

#### File Path Issues
```python
# Problem: File not found
FileNotFoundError: [Errno 2] No such file or directory

# Solution: Use pathlib for cross-platform paths
from pathlib import Path

csv_path = Path("M:/Albums/_inventory_.csv")
if csv_path.exists():
    # Process file
else:
    logger.warning(f"CSV file not found: {csv_path}")
```

#### Memory Issues
```python
# Problem: Memory usage too high
MemoryError: Unable to allocate array

# Solution: Process data in chunks
def process_large_csv(file_path: str, chunk_size: int = 1000):
    """Process large CSV files in chunks."""
    for chunk in pd.read_csv(file_path, chunksize=chunk_size):
        yield process_chunk(chunk)

# Use generator pattern
for processed_chunk in process_large_csv("large_file.csv"):
    # Process each chunk
    pass
```

### Performance Issues

#### Slow CSV Loading
```python
# Problem: CSV loading takes too long
# Solution: Optimize pandas operations

# Use specific data types
dtype_dict = {
    'title': 'string',
    'artist': 'string',
    'album': 'string',
    'size_bytes': 'int64',
    'length_seconds': 'float64'
}

df = pd.read_csv(file_path, dtype=dtype_dict)

# Use only needed columns
needed_columns = ['title', 'artist', 'album', 'size_bytes']
df = pd.read_csv(file_path, usecols=needed_columns)
```

#### Slow Frontend Rendering
```javascript
// Problem: UI is sluggish with large datasets
// Solution: Implement virtualization

class VirtualGrid {
  constructor(container, items, itemWidth, itemHeight) {
    this.container = container;
    this.items = items;
    this.itemWidth = itemWidth;
    this.itemHeight = itemHeight;
    
    this.setupVirtualization();
  }
  
  setupVirtualization() {
    // Only render visible items
    this.renderVisibleItems();
    
    // Update on scroll
    this.container.addEventListener('scroll', () => {
      requestAnimationFrame(() => this.renderVisibleItems());
    });
  }
}
```

### Debugging Tools

#### Python Debugging
```python
import pdb
import logging

# Set breakpoint
def debug_function():
    pdb.set_trace()  # Debugger will stop here
    # Your code here

# Enhanced logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

def debug_with_logging():
    logger.debug("Function entry")
    try:
        result = complex_operation()
        logger.debug(f"Operation result: {result}")
        return result
    except Exception as e:
        logger.error(f"Operation failed: {e}", exc_info=True)
        raise
```

#### Browser Debugging
```javascript
// Enhanced console logging
const DEBUG = {
  enabled: true,
  level: 'info', // 'debug', 'info', 'warn', 'error'
  
  log(level, message, data) {
    if (!this.enabled) return;
    
    const levels = ['debug', 'info', 'warn', 'error'];
    if (levels.indexOf(level) >= levels.indexOf(this.level)) {
      console[level](`[${level.toUpperCase()}] ${message}`, data);
    }
  },
  
  debug(message, data) { this.log('debug', message, data); },
  info(message, data) { this.log('info', message, data); },
  warn(message, data) { this.log('warn', message, data); },
  error(message, data) { this.log('error', message, data); }
};

// Use in your code
DEBUG.info('Loading catalog data', { count: 1000 });
```

---

**This development guide provides comprehensive coverage for developers working with the EchoVerse Music Catalog system.**

*For user documentation, see USER_GUIDE.md. For API details, see API_REFERENCE.md.*
