/**
 * EchoVerse Music Metadata Manager
 * Handles persistent metadata storage and retrieval for songs
 */

class MetadataManager {
    constructor() {
        this.metadata = {};
        this.storageKey = 'echoverse_metadata';
        this.loadMetadata();
    }

    /**
     * Load metadata from localStorage or initialize with defaults
     */
    loadMetadata() {
        try {
            const stored = localStorage.getItem(this.storageKey);
            if (stored) {
                this.metadata = JSON.parse(stored);
            } else {
                this.initializeDefaultMetadata();
            }
        } catch (error) {
            console.error('Error loading metadata:', error);
            this.initializeDefaultMetadata();
        }
    }

    /**
     * Initialize with default metadata structure
     */
    initializeDefaultMetadata() {
        this.metadata = {
            metadata_version: "1.0",
            last_updated: new Date().toISOString(),
            songs: {},
            tags: {},
            playlists: {},
            statistics: {
                total_songs: 0,
                total_play_count: 0,
                average_rating: 0,
                most_played: null,
                favorite_count: 0,
                total_tags: 0,
                last_activity: new Date().toISOString()
            }
        };
    }

    /**
     * Save metadata to localStorage
     */
    saveMetadata() {
        try {
            this.metadata.last_updated = new Date().toISOString();
            localStorage.setItem(this.storageKey, JSON.stringify(this.metadata));
            return true;
        } catch (error) {
            console.error('Error saving metadata:', error);
            return false;
        }
    }

    /**
     * Generate unique ID for a song based on file hash or content
     */
    generateSongId(fileName, fileSize, lastModified) {
        // Create a unique identifier based on file properties
        const content = `${fileName}_${fileSize}_${lastModified}`;
        return this.simpleHash(content);
    }

    /**
     * Simple hash function for generating unique IDs
     */
    simpleHash(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return Math.abs(hash).toString(16);
    }

    /**
     * Get metadata for a song
     */
    getSongMetadata(songId) {
        return this.metadata.songs[songId] || null;
    }

    /**
     * Create or update song metadata
     */
    setSongMetadata(songId, metadata) {
        const existing = this.metadata.songs[songId] || {};
        
        this.metadata.songs[songId] = {
            unique_id: songId,
            file_name: metadata.file_name || existing.file_name || '',
            title: metadata.title || existing.title || '',
            artist: metadata.artist || existing.artist || '',
            album: metadata.album || existing.album || '',
            rating: metadata.rating !== undefined ? metadata.rating : (existing.rating || 0),
            notes: metadata.notes || existing.notes || '',
            tags: metadata.tags || existing.tags || [],
            play_count: metadata.play_count !== undefined ? metadata.play_count : (existing.play_count || 0),
            last_played: metadata.last_played || existing.last_played || null,
            favorite: metadata.favorite !== undefined ? metadata.favorite : (existing.favorite || false),
            created_date: existing.created_date || new Date().toISOString(),
            modified_date: new Date().toISOString(),
            custom_fields: metadata.custom_fields || existing.custom_fields || {}
        };

        this.updateTagCounts();
        this.updateStatistics();
        this.saveMetadata();
        
        return this.metadata.songs[songId];
    }

    /**
     * Update song rating
     */
    setSongRating(songId, rating) {
        if (this.metadata.songs[songId]) {
            this.metadata.songs[songId].rating = Math.max(0, Math.min(5, rating));
            this.metadata.songs[songId].modified_date = new Date().toISOString();
            this.updateStatistics();
            this.saveMetadata();
        }
    }

    /**
     * Update song notes
     */
    setSongNotes(songId, notes) {
        if (this.metadata.songs[songId]) {
            this.metadata.songs[songId].notes = notes;
            this.metadata.songs[songId].modified_date = new Date().toISOString();
            this.saveMetadata();
        }
    }

    /**
     * Add or remove tags from a song
     */
    setSongTags(songId, tags) {
        if (this.metadata.songs[songId]) {
            this.metadata.songs[songId].tags = Array.isArray(tags) ? tags : [];
            this.metadata.songs[songId].modified_date = new Date().toISOString();
            this.updateTagCounts();
            this.saveMetadata();
        }
    }

    /**
     * Toggle favorite status
     */
    toggleFavorite(songId) {
        if (this.metadata.songs[songId]) {
            this.metadata.songs[songId].favorite = !this.metadata.songs[songId].favorite;
            this.metadata.songs[songId].modified_date = new Date().toISOString();
            this.updateStatistics();
            this.saveMetadata();
        }
    }

    /**
     * Increment play count
     */
    incrementPlayCount(songId) {
        if (this.metadata.songs[songId]) {
            this.metadata.songs[songId].play_count = (this.metadata.songs[songId].play_count || 0) + 1;
            this.metadata.songs[songId].last_played = new Date().toISOString();
            this.updateStatistics();
            this.saveMetadata();
        }
    }

    /**
     * Search songs by various criteria
     */
    searchSongs(criteria) {
        const results = [];
        
        Object.values(this.metadata.songs).forEach(song => {
            let matches = true;
            
            if (criteria.search) {
                const searchTerm = criteria.search.toLowerCase();
                matches = matches && (
                    song.title.toLowerCase().includes(searchTerm) ||
                    song.artist.toLowerCase().includes(searchTerm) ||
                    song.album.toLowerCase().includes(searchTerm) ||
                    song.notes.toLowerCase().includes(searchTerm) ||
                    song.tags.some(tag => tag.toLowerCase().includes(searchTerm))
                );
            }
            
            if (criteria.favorites) {
                matches = matches && song.favorite;
            }
            
            if (criteria.minRating) {
                matches = matches && song.rating >= criteria.minRating;
            }
            
            if (criteria.tags && criteria.tags.length > 0) {
                matches = matches && criteria.tags.some(tag => song.tags.includes(tag));
            }
            
            if (matches) {
                results.push(song);
            }
        });
        
        return results;
    }

    /**
     * Get all unique tags
     */
    getAllTags() {
        const tagSet = new Set();
        Object.values(this.metadata.songs).forEach(song => {
            song.tags.forEach(tag => tagSet.add(tag));
        });
        return Array.from(tagSet);
    }

    /**
     * Get statistics
     */
    getStatistics() {
        return this.metadata.statistics;
    }

    /**
     * Update tag counts
     */
    updateTagCounts() {
        this.metadata.tags = {};
        const tagCounts = {};
        
        Object.values(this.metadata.songs).forEach(song => {
            song.tags.forEach(tag => {
                tagCounts[tag] = (tagCounts[tag] || 0) + 1;
            });
        });
        
        Object.keys(tagCounts).forEach(tag => {
            this.metadata.tags[tag] = {
                count: tagCounts[tag],
                color: this.generateTagColor(tag),
                description: `Songs tagged with ${tag}`
            };
        });
    }

    /**
     * Generate a consistent color for a tag
     */
    generateTagColor(tag) {
        const colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#feca57', '#ff9ff3', '#a8e6cf', '#ffd3a5'];
        const hash = this.simpleHash(tag);
        return colors[parseInt(hash, 16) % colors.length];
    }

    /**
     * Update statistics
     */
    updateStatistics() {
        const songs = Object.values(this.metadata.songs);
        
        this.metadata.statistics = {
            total_songs: songs.length,
            total_play_count: songs.reduce((sum, song) => sum + (song.play_count || 0), 0),
            average_rating: songs.length > 0 ? 
                (songs.reduce((sum, song) => sum + (song.rating || 0), 0) / songs.length).toFixed(1) : 0,
            most_played: songs.reduce((max, song) => 
                (song.play_count || 0) > (max.play_count || 0) ? song : max, songs[0] || null),
            favorite_count: songs.filter(song => song.favorite).length,
            total_tags: this.getAllTags().length,
            last_activity: new Date().toISOString()
        };
    }

    /**
     * Create a playlist
     */
    createPlaylist(name, description, songIds) {
        const playlistId = this.simpleHash(name + Date.now());
        this.metadata.playlists[playlistId] = {
            id: playlistId,
            name,
            description,
            songs: songIds || [],
            created_date: new Date().toISOString(),
            modified_date: new Date().toISOString()
        };
        this.saveMetadata();
        return playlistId;
    }

    /**
     * Get all playlists
     */
    getPlaylists() {
        return this.metadata.playlists;
    }

    /**
     * Add song to playlist
     */
    addSongToPlaylist(playlistId, songId) {
        if (this.metadata.playlists[playlistId]) {
            if (!this.metadata.playlists[playlistId].songs.includes(songId)) {
                this.metadata.playlists[playlistId].songs.push(songId);
                this.metadata.playlists[playlistId].modified_date = new Date().toISOString();
                this.saveMetadata();
            }
        }
    }

    /**
     * Remove song from playlist
     */
    removeSongFromPlaylist(playlistId, songId) {
        if (this.metadata.playlists[playlistId]) {
            this.metadata.playlists[playlistId].songs = 
                this.metadata.playlists[playlistId].songs.filter(id => id !== songId);
            this.metadata.playlists[playlistId].modified_date = new Date().toISOString();
            this.saveMetadata();
        }
    }

    /**
     * Export metadata to JSON
     */
    exportMetadata() {
        return JSON.stringify(this.metadata, null, 2);
    }

    /**
     * Import metadata from JSON
     */
    importMetadata(jsonData) {
        try {
            const imported = JSON.parse(jsonData);
            if (imported.songs && imported.tags && imported.statistics) {
                this.metadata = imported;
                this.saveMetadata();
                return true;
            }
        } catch (error) {
            console.error('Error importing metadata:', error);
        }
        return false;
    }

    /**
     * Clear all metadata
     */
    clearAllMetadata() {
        this.initializeDefaultMetadata();
        this.saveMetadata();
    }

    /**
     * Get songs by rating
     */
    getSongsByRating(minRating) {
        return Object.values(this.metadata.songs).filter(song => song.rating >= minRating);
    }

    /**
     * Get favorite songs
     */
    getFavoriteSongs() {
        return Object.values(this.metadata.songs).filter(song => song.favorite);
    }

    /**
     * Get most played songs
     */
    getMostPlayedSongs(limit = 10) {
        return Object.values(this.metadata.songs)
            .sort((a, b) => (b.play_count || 0) - (a.play_count || 0))
            .slice(0, limit);
    }

    /**
     * Get recently played songs
     */
    getRecentlyPlayedSongs(limit = 10) {
        return Object.values(this.metadata.songs)
            .filter(song => song.last_played)
            .sort((a, b) => new Date(b.last_played) - new Date(a.last_played))
            .slice(0, limit);
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = MetadataManager;
} else {
    window.MetadataManager = MetadataManager;
}
