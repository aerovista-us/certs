# EchoVerse Music Catalog - User Guide

Complete user guide for the EchoVerse Music Catalog system, covering all features, workflows, and best practices for music professionals and enthusiasts.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Basic Navigation](#basic-navigation)
- [Browsing Your Music](#browsing-your-music)
- [Search and Filter](#search-and-filter)
- [Work Order System](#work-order-system)
- [Album Art Gallery](#album-art-gallery)
- [Advanced Features](#advanced-features)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Tips and Tricks](#tips-and-tricks)
- [Troubleshooting](#troubleshooting)
- [Frequently Asked Questions](#frequently-asked-questions)

## 🚀 Getting Started

### First Launch
1. **Start the System**: Double-click `start_catalog.bat` or run `python main.py`
2. **Wait for Loading**: The system will scan for your music inventory
3. **Open Browser**: Navigate to `http://localhost:8000`
4. **Welcome Screen**: You'll see the main dashboard with your music collection

### System Requirements
- **Operating System**: Windows 10/11
- **Browser**: Modern browser (Chrome, Firefox, Edge, Safari)
- **Music Files**: Accessible via mapped drive `M:\Albums\`
- **Inventory File**: CSV file with naming pattern `_inventory_*.csv`

### Initial Setup
The system automatically:
- Finds your most recent music inventory CSV
- Loads all music metadata
- Generates unique IDs for tracks, albums, and artists
- Prepares the browsing interface

## 🧭 Basic Navigation

### Header Navigation
The top of the page contains navigation links:
- **🎵 Music Catalog**: Main dashboard (current page)
- **🖼️ Album Art Gallery**: Dedicated album art browsing
- **📋 Work Orders**: Project management system

### Dashboard Layout
- **Statistics Panel**: Collection overview at the top
- **Search Bar**: Quick music discovery
- **Music Grid**: Album and track display
- **Work Order Builder**: Project creation tools

### Page Navigation
- **Back Button**: Return to previous page
- **Home Link**: Return to main dashboard
- **Breadcrumbs**: Navigate between sections

## 🎵 Browsing Your Music

### Album View
Each album is displayed as a card showing:
- **Album Cover**: High-quality cover art (when available)
- **Album Title**: Name of the album
- **Artist Name**: Recording artist
- **Track Count**: Number of tracks in the album
- **Total Duration**: Combined length of all tracks
- **Unique ID**: System identifier for the album

### Track View
Click on an album to see individual tracks:
- **Track Name**: Song title
- **Duration**: Length of the track
- **File Size**: Size in bytes or MB
- **Track Number**: Position in album
- **Actions**: Add to work order, play, view lyrics, trace relationships

### View Modes
- **Grid View**: Compact album display (default)
- **List View**: Detailed track listing
- **Gallery View**: Focus on album artwork

## 🔍 Search and Filter

### Quick Search
- **Search Bar**: Type any text to search across:
  - Track titles
  - Album names
  - Artist names
  - Genres
  - Years
- **Real-time Results**: See matches as you type
- **Clear Search**: Click the X button to reset

### Advanced Filtering
- **Genre Filter**: Browse by music genre
- **Year Filter**: Find music from specific years
- **Artist Filter**: Focus on specific artists
- **Duration Filter**: Find short or long tracks

### Sorting Options
- **Alphabetical**: Sort by name (A-Z or Z-A)
- **Chronological**: Sort by year (newest/oldest)
- **Duration**: Sort by track length
- **File Size**: Sort by file size
- **Track Number**: Sort by album position

## 📋 Work Order System

### Creating Work Orders
1. **Select Tracks**: Click the "➕ Add" button on tracks you want to include
2. **Navigate to Work Orders**: Click "📋 Work Orders" in the header
3. **Choose Type**: Select from available work order types:
   - **Playlist**: Custom track collection
   - **Album Production**: New album creation
   - **Remix Project**: Remix existing tracks
   - **Reference Material**: Collection for inspiration
   - **Mastering Project**: Audio mastering work
4. **Add Details**: Fill in title, description, and priority
5. **Create Order**: Click "Create Work Order"

### Work Order Types

#### Playlist Creation
- **Purpose**: Create custom track collections
- **Use Cases**: DJ sets, workout music, mood playlists
- **Features**: Reorder tracks, add descriptions, set themes

#### Album Production
- **Purpose**: Plan new album releases
- **Use Cases**: Studio recording, compilation albums
- **Features**: Track sequencing, production notes, timeline planning

#### Remix Project
- **Purpose**: Plan remix and derivative works
- **Use Cases**: Remix albums, cover versions, mashups
- **Features**: Source track identification, remix notes, licensing info

#### Reference Material
- **Purpose**: Collect inspiration and reference tracks
- **Use Cases**: Style research, production inspiration, genre study
- **Features**: Categorization, notes, comparison tools

#### Mastering Project
- **Purpose**: Plan audio mastering work
- **Use Cases**: Album mastering, single mastering, compilation mastering
- **Features**: Track grouping, mastering notes, quality targets

### Managing Work Orders
- **View All**: See all created work orders
- **Edit**: Modify existing work orders
- **Delete**: Remove completed or unwanted orders
- **Export**: Download as JSON for external tools
- **Status Tracking**: Monitor progress and completion

### Work Order Priority Levels
- **Low**: Non-urgent projects
- **Medium**: Standard priority work
- **High**: Important projects
- **Urgent**: Time-critical work

## 🖼️ Album Art Gallery

### Accessing the Gallery
1. **Click "🖼️ Album Art Gallery"** in the header navigation
2. **Browse Covers**: View all album artwork in a dedicated space
3. **Return to Dashboard**: Use the "← Back to Dashboard" link

### Gallery Features
- **Grid Layout**: Organized display of all album covers
- **Sorting Options**: Arrange by various criteria
- **View Modes**: Switch between grid and list views
- **Quick Navigation**: Easy access to album details

### Using the Gallery
- **Browse Visually**: Find albums by their cover art
- **Click Covers**: Open full-size images
- **Identify Albums**: See album names and artists
- **Plan Projects**: Use visual browsing for work order planning

## ⚡ Advanced Features

### Unique ID System
Every track, album, and artist has a unique identifier:
- **Track IDs**: `track_a1b2c3_album_x9y8z7_artist_m5n6o7`
- **Album IDs**: `album_x9y8z7_artist_m5n6o7`
- **Artist IDs**: `artist_m5n6o7`

#### Tracing Relationships
1. **Click "🔗 Trace"** on any track
2. **View Hierarchy**: See track → album → artist relationships
3. **Navigate**: Use IDs for external tool integration
4. **Understand**: See how everything connects

### Lazy Loading
- **Performance**: Images load only when visible
- **Smooth Scrolling**: Faster browsing through large collections
- **Bandwidth**: Efficient use of system resources
- **User Experience**: Responsive interface even with many images

### Statistics Panel
The dashboard shows collection overview:
- **Total Files**: Complete file count
- **Total Size**: Combined storage size
- **Audio Files**: Number of music tracks
- **Albums**: Number of unique albums
- **Artists**: Number of unique artists

## ⌨️ Keyboard Shortcuts

### Navigation
- **Tab**: Navigate between interactive elements
- **Enter/Space**: Activate buttons and links
- **Arrow Keys**: Navigate through lists and grids
- **Escape**: Close modals and dialogs

### Search
- **Ctrl+F**: Focus search bar
- **Enter**: Execute search
- **Escape**: Clear search

### Work Orders
- **Ctrl+N**: Create new work order
- **Ctrl+S**: Save work order
- **Delete**: Remove selected tracks

## 💡 Tips and Tricks

### Efficient Browsing
1. **Use Search**: Type partial names for quick finding
2. **Filter by Genre**: Focus on specific music styles
3. **Sort by Year**: Discover music from specific time periods
4. **Browse by Artist**: Focus on favorite musicians

### Work Order Best Practices
1. **Plan Ahead**: Create work orders before starting projects
2. **Use Descriptions**: Add detailed notes for clarity
3. **Set Priorities**: Organize work by importance
4. **Export Regularly**: Save work orders for external tools

### Performance Optimization
1. **Close Unused Tabs**: Reduce memory usage
2. **Use Lazy Loading**: Let images load as needed
3. **Clear Search**: Reset filters for faster browsing
4. **Restart Server**: Refresh if performance degrades

### File Organization
1. **Consistent Naming**: Use clear file and folder names
2. **Cover Art**: Include high-quality album covers
3. **Metadata**: Ensure accurate track information
4. **Regular Updates**: Refresh inventory files

## 🚨 Troubleshooting

### Common Issues

#### No Music Displayed
**Problem**: Dashboard shows no albums or tracks
**Solutions**:
1. Check if CSV file exists in expected locations
2. Verify file paths in CSV match actual music locations
3. Ensure music files are accessible
4. Check browser console for error messages

#### Images Not Loading
**Problem**: Album covers not displaying
**Solutions**:
1. Verify cover art file paths
2. Check image file formats (JPEG, PNG, etc.)
3. Ensure file permissions allow access
4. Look for 404 errors in browser console

#### Server Won't Start
**Problem**: FastAPI server fails to launch
**Solutions**:
1. Check Python installation (3.8+ required)
2. Verify virtual environment activation
3. Check if port 8000 is available
4. Review console error messages

#### Slow Performance
**Problem**: Interface is sluggish or unresponsive
**Solutions**:
1. Reduce CSV file size
2. Optimize image formats
3. Check available system memory
4. Use lazy loading for large collections

### Error Messages

#### "CSV not found"
- Verify inventory file location
- Check file naming pattern (`_inventory_*.csv`)
- Ensure file is readable

#### "Permission denied"
- Check file and directory permissions
- Verify user access rights
- Ensure music files are accessible

#### "Port already in use"
- Change port in main.py
- Stop conflicting services
- Use different port number

### Getting Help
1. **Check Console**: Look for error messages
2. **Review Logs**: Check server output
3. **Browser Tools**: Use developer console
4. **Documentation**: Refer to this guide and README

## ❓ Frequently Asked Questions

### General Questions

**Q: How do I add new music to the catalog?**
A: The system automatically detects new inventory CSV files. Simply place a new `_inventory_*.csv` file in one of the monitored locations, and restart the server.

**Q: Can I use this with music on external drives?**
A: Yes, as long as the drive is accessible via the file paths in your CSV file. The system works with any accessible file location.

**Q: How do I backup my work orders?**
A: Work orders are stored in `work_orders.json`. Simply copy this file to backup your projects.

**Q: Can I share my music catalog with others?**
A: The system runs locally, but you can export work orders as JSON to share project information with collaborators.

### Technical Questions

**Q: What music formats are supported?**
A: The system works with any audio format. The CSV inventory should contain the file paths, and the system will display them regardless of format.

**Q: How do I change the server port?**
A: Edit `main.py` and change the port number in the `uvicorn.run()` call, then restart the server.

**Q: Can I customize the interface?**
A: Yes, you can modify the HTML templates in the `templates/` directory to customize colors, layout, and functionality.

**Q: How do I add new work order types?**
A: Edit the HTML templates to add new work order types in the select dropdown, and update the backend logic in `main.py` if needed.

### Workflow Questions

**Q: How do I create a playlist for a specific mood?**
A: Use the search and filter features to find tracks matching your mood, add them to a work order, and set the type to "Playlist".

**Q: Can I plan an album production workflow?**
A: Yes, create a work order with type "Album Production", add reference tracks, and use the description field for production notes.

**Q: How do I organize tracks for remixing?**
A: Create a "Remix Project" work order, add source tracks, and use the description for remix notes and licensing information.

**Q: Can I track mastering projects?**
A: Yes, use "Mastering Project" work orders to group tracks, add mastering notes, and track quality targets.

## 📚 Additional Resources

### Documentation
- **README.md**: Project overview and setup
- **API_REFERENCE.md**: Technical API documentation
- **ARCHITECTURE.md**: System design and architecture

### Support
- **Console Logs**: Check server output for errors
- **Browser Tools**: Use developer console for debugging
- **File System**: Verify music file accessibility
- **Community**: Share issues with the NeXuS community

### Updates
- **Regular Updates**: Check for new features and improvements
- **Feature Requests**: Suggest new functionality
- **Bug Reports**: Report issues for resolution
- **Contributions**: Help improve the system

---

**This user guide provides comprehensive coverage of all EchoVerse Music Catalog features and workflows.**

*For technical details, see the API_REFERENCE.md and ARCHITECTURE.md documents.*
