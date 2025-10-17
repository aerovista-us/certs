# EchoVerse Music Catalog

A comprehensive, AI-powered music catalog system built with FastAPI and modern web technologies, designed for professional music engineers and enthusiasts who need powerful tools to organize, browse, and work with large music collections.

## 🎯 Project Overview

EchoVerse Music Catalog transforms your music library into an intelligent, searchable, and work-order-driven system. Built on the NeXuS AI stack, it provides:

- **Smart Music Organization**: AI-powered categorization and metadata management
- **Professional Work Orders**: Create playlists, albums, and remix projects
- **Advanced Browsing**: Multiple view modes with lazy loading and relationship tracing
- **Unique ID System**: Hierarchical tracing across tracks, albums, and artists
- **Local-First Architecture**: Works entirely offline with your local music files

## 🏗️ Architecture

### Backend (FastAPI)
- **FastAPI Server**: High-performance async web framework
- **CSV Processing**: Intelligent inventory parsing with automatic fallbacks
- **Unique ID Generation**: Hash-based hierarchical relationship system
- **File Serving**: Direct access to music files, album art, and lyrics
- **Work Order Management**: JSON-based project tracking system

### Frontend (HTML/CSS/JavaScript)
- **Responsive Dashboard**: Modern glassmorphism design with dark theme
- **Lazy Loading**: Optimized image loading for large collections
- **Interactive Grid**: Sortable, filterable, and groupable music display
- **Album Art Gallery**: Dedicated page for visual browsing
- **Work Order Builder**: Drag-and-drop playlist and project creation

### Data Flow
```
CSV Inventory → FastAPI Processing → Unique ID Generation → Frontend Display
     ↓                    ↓                    ↓              ↓
Music Files → Album Art Detection → Relationship Mapping → User Interface
```

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Windows 10/11 (with mapped drive M:\Albums)
- Music inventory CSV file (format: `_inventory_*.csv`)

### Installation
1. **Clone/Download** the project to your desired location
2. **Run the setup script**:
   ```bash
   start_catalog.bat
   ```
   This will:
   - Create a Python virtual environment
   - Install all dependencies
   - Start the FastAPI server

3. **Access the catalog** at `http://localhost:8000`

### Manual Setup
```bash
# Create virtual environment
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start server
python main.py
```

## 📁 Project Structure

```
EchoVerse_Music_Catalog/
├── main.py                 # FastAPI backend server
├── requirements.txt        # Python dependencies
├── start_catalog.bat      # Windows startup script
├── templates/             # HTML templates
│   ├── dashboard.html     # Main catalog interface
│   └── gallery.html       # Album art gallery
├── music/                 # Static music files (placeholder)
├── work_orders.json       # Work order storage
└── README.md             # This documentation
```

## 🔧 Configuration

### CSV File Requirements
The system automatically detects and loads the most recent `_inventory_*.csv` file from:
- `M:\Albums\` (primary mapped drive)
- `D:\Clients\AeroVista\Projects\EchoVerse_Music\Albums\`
- `C:\Users\[username]\Desktop\`

**Required CSV Columns:**
- `title` - Track title
- `artist` - Artist name
- `album` - Album name
- `full_path` - Full file path
- `size_bytes` - File size in bytes
- `length_seconds` - Duration in seconds
- `track_number` - Track number
- `year` - Release year
- `genre` - Music genre
- `bitrate` - Audio bitrate
- `sample_rate` - Sample rate
- `file_name` - Original filename

### Drive Mapping
Ensure your music collection is accessible via `M:\Albums\` or update the paths in `main.py`.

## 🌟 Features

### 1. Intelligent Music Catalog
- **Automatic CSV Loading**: Finds and loads the most recent inventory
- **Metadata Fallbacks**: Uses filename when title metadata is missing
- **Album Art Detection**: Automatically finds cover images
- **File Size & Duration**: Comprehensive file information display

### 2. Unique ID System
- **Hierarchical Tracing**: Track relationships across music entities
- **Hash-Based IDs**: Consistent identification across sessions
- **Relationship Mapping**: Navigate from track → album → artist
- **Trace API**: Query detailed relationship information

### 3. Advanced Browsing
- **Multiple View Modes**: Grid, list, and gallery views
- **Smart Grouping**: Group by album, artist, genre, or year
- **Advanced Filtering**: Multi-criteria search and filtering
- **Sorting Options**: Sort by any metadata field

### 4. Work Order System
- **Playlist Creation**: Build custom track collections
- **Project Management**: Create albums, remixes, and compilations
- **Export Options**: JSON format for external tools
- **Task Assignment**: Professional workflow management

### 5. Performance Features
- **Lazy Loading**: Images load only when visible
- **Efficient Search**: Fast filtering and sorting
- **Responsive Design**: Works on all device sizes
- **Offline Operation**: No internet connection required

## 🔌 API Endpoints

### Core Endpoints
- `GET /` - Main dashboard
- `GET /gallery` - Album art gallery
- `GET /health` - Server health check

### Data Endpoints
- `GET /api/catalog` - Full music catalog
- `GET /api/albums` - Albums grouped by artist
- `GET /api/search` - Search across all metadata
- `GET /api/album-art/{album_name}` - Album cover image

### ID System Endpoints
- `GET /api/track/{track_id}` - Track details with relationships
- `GET /api/album/{album_id}` - Album details with relationships

### Work Order Endpoints
- `GET /api/work-orders` - List all work orders
- `POST /api/work-orders` - Create new work order
- `PUT /api/work-orders/{id}` - Update existing work order
- `DELETE /api/work-orders/{id}` - Delete work order

## 🎨 User Interface

### Dashboard Features
- **Statistics Panel**: Collection overview and metrics
- **Search & Filter**: Advanced music discovery tools
- **Music Grid**: Visual album and track browsing
- **Work Order Builder**: Professional project creation
- **Navigation**: Quick access to all features

### Gallery Features
- **Album Art Display**: High-quality cover image browsing
- **Sorting Options**: Organize by various criteria
- **View Modes**: Grid and list layouts
- **Quick Navigation**: Return to main dashboard

### Responsive Design
- **Mobile Optimized**: Touch-friendly interface
- **Desktop Enhanced**: Full-featured desktop experience
- **Cross-Browser**: Works in all modern browsers
- **Accessibility**: Screen reader and keyboard navigation support

## 🔍 Usage Examples

### Basic Browsing
1. Open the catalog at `http://localhost:8000`
2. Browse albums in the main grid
3. Click on albums to see track details
4. Use search and filters to find specific music

### Creating Work Orders
1. Select tracks by clicking the "➕ Add" button
2. Navigate to the Work Orders section
3. Choose work order type (playlist, album, remix)
4. Add project details and export as JSON

### Using the ID System
1. Click the "🔗 Trace" button on any track
2. View the relationship hierarchy
3. Navigate between related entities
4. Use IDs for external tool integration

### Album Art Gallery
1. Click "🖼️ Album Art Gallery" in the header
2. Browse covers in various view modes
3. Sort by different criteria
4. Return to main dashboard when done

## 🛠️ Development

### Adding New Features
1. **Backend**: Extend `main.py` with new endpoints
2. **Frontend**: Modify HTML templates and JavaScript
3. **Testing**: Use the built-in development server
4. **Deployment**: Update requirements and restart server

### Customization
- **Styling**: Modify CSS in template files
- **Functionality**: Extend JavaScript functions
- **Data Processing**: Enhance CSV parsing logic
- **API**: Add new endpoints and data structures

### Debugging
- **Server Logs**: Check console output for errors
- **Browser Console**: View JavaScript errors and network requests
- **API Testing**: Use browser dev tools or curl for endpoint testing
- **File Paths**: Verify music file accessibility

## 📊 Performance Considerations

### Large Collections
- **Lazy Loading**: Images load on-demand
- **Efficient Filtering**: Client-side processing for speed
- **Memory Management**: Optimized data structures
- **Caching**: Browser-level caching for static assets

### Optimization Tips
- **CSV Size**: Keep inventory files under 100MB
- **Image Formats**: Use compressed image formats (JPEG, WebP)
- **File Paths**: Minimize path length and complexity
- **Regular Updates**: Refresh inventory data periodically

## 🔒 Security & Privacy

### Local Operation
- **No Internet**: Works entirely offline
- **File Access**: Only reads specified music directories
- **No Data Collection**: All data stays on your system
- **User Control**: Full control over data and access

### Best Practices
- **File Permissions**: Restrict access to music directories
- **Network Security**: Use localhost or secure networks
- **Regular Backups**: Backup work orders and configuration
- **Access Control**: Limit server access to trusted users

## 🚨 Troubleshooting

### Common Issues

#### Server Won't Start
- Check Python installation and version
- Verify virtual environment activation
- Check port 8000 availability
- Review error messages in console

#### No Music Displayed
- Verify CSV file exists and is readable
- Check file paths in CSV match actual locations
- Ensure music files are accessible
- Review CSV column names and format

#### Images Not Loading
- Check album art file paths
- Verify image file formats (JPEG, PNG, etc.)
- Check file permissions
- Review browser console for errors

#### Performance Issues
- Reduce CSV file size
- Optimize image formats
- Check available system memory
- Use lazy loading for large collections

### Error Messages
- **"Directory 'music' does not exist"**: Create music directory or remove static mount
- **"CSV not found"**: Verify inventory file location and naming
- **"Permission denied"**: Check file and directory permissions
- **"Port already in use"**: Change port in main.py or stop conflicting service

## 🔮 Future Enhancements

### Planned Features
- **Audio Preview**: Stream music samples
- **Lyrics Integration**: Automatic lyrics detection and display
- **Advanced Analytics**: Music collection insights and statistics
- **Export Formats**: Multiple export options (CSV, XML, etc.)
- **Plugin System**: Extensible architecture for custom features

### Integration Opportunities
- **Music Players**: Integration with popular audio software
- **Cloud Storage**: Support for cloud-based music collections
- **Social Features**: Sharing playlists and recommendations
- **AI Enhancement**: Machine learning for music discovery

## 📞 Support

### Getting Help
1. **Check Documentation**: Review this README and code comments
2. **Console Logs**: Look for error messages and warnings
3. **Browser Tools**: Use developer tools for debugging
4. **Community**: Share issues and solutions with the NeXuS community

### Contributing
- **Bug Reports**: Document issues with steps to reproduce
- **Feature Requests**: Suggest new functionality and improvements
- **Code Contributions**: Submit pull requests for enhancements
- **Documentation**: Help improve and expand documentation

## 📄 License

This project is part of the NeXuS ecosystem and follows the same licensing terms. See the main NeXuS repository for license information.

## 🙏 Acknowledgments

- **NeXuS Team**: For the AI-powered foundation
- **FastAPI Community**: For the excellent web framework
- **Music Engineering Community**: For feedback and feature requests
- **Open Source Contributors**: For the tools and libraries used

---

**EchoVerse Music Catalog** - Transforming music management with AI-powered intelligence and professional workflow tools.

*Built with ❤️ for music professionals and enthusiasts.*
