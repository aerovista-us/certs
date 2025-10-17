/**
 * EchoVerse Context Menu System
 * Provides content-aware right-click menus for songs and other elements
 */

class ContextMenu {
    constructor() {
        this.menu = null;
        this.currentTarget = null;
        this.metadataManager = null;
        this.audioPlayer = null;
        this.initializeMenu();
        this.attachEventListeners();
    }

    /**
     * Initialize the context menu
     */
    initializeMenu() {
        // Create context menu element
        this.menu = document.createElement('div');
        this.menu.id = 'contextMenu';
        this.menu.className = 'context-menu';
        this.menu.style.cssText = `
            position: fixed;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 12px;
            padding: 8px 0;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            z-index: 10000;
            display: none;
            min-width: 200px;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            font-size: 14px;
            color: #333;
        `;

        document.body.appendChild(this.menu);
    }

    /**
     * Attach event listeners
     */
    attachEventListeners() {
        // Hide menu on click outside
        document.addEventListener('click', (e) => {
            if (!this.menu.contains(e.target)) {
                this.hide();
            }
        });

        // Hide menu on scroll
        document.addEventListener('scroll', () => {
            this.hide();
        });

        // Hide menu on escape key
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                this.hide();
            }
        });
    }

    /**
     * Show context menu for a song
     */
    showSongMenu(event, songData) {
        event.preventDefault();
        this.currentTarget = songData;
        
        // Clear existing menu items
        this.menu.innerHTML = '';
        
        // Create menu items
        const menuItems = this.createSongMenuItems(songData);
        
        menuItems.forEach(item => {
            const menuItem = document.createElement('div');
            menuItem.className = 'context-menu-item';
            menuItem.style.cssText = `
                padding: 12px 16px;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 12px;
                transition: background-color 0.2s ease;
                border-bottom: 1px solid rgba(0, 0, 0, 0.1);
            `;
            
            menuItem.innerHTML = `
                <span style="font-size: 16px;">${item.icon}</span>
                <span>${item.text}</span>
                ${item.shortcut ? `<span style="margin-left: auto; color: #666; font-size: 12px;">${item.shortcut}</span>` : ''}
            `;
            
            menuItem.addEventListener('click', (e) => {
                e.stopPropagation();
                item.action(songData);
                this.hide();
            });
            
            menuItem.addEventListener('mouseenter', () => {
                menuItem.style.backgroundColor = 'rgba(102, 126, 234, 0.1)';
            });
            
            menuItem.addEventListener('mouseleave', () => {
                menuItem.style.backgroundColor = 'transparent';
            });
            
            this.menu.appendChild(menuItem);
        });
        
        // Position menu
        this.positionMenu(event);
        this.show();
    }

    /**
     * Create menu items for songs
     */
    createSongMenuItems(songData) {
        const songId = this.generateSongId(songData);
        const currentRating = this.getCurrentRating(songId);
        const currentNote = this.getCurrentNote(songId);
        const isInWorkOrder = this.isInWorkOrder(songId);
        
        return [
            {
                icon: '🎵',
                text: 'Play Now',
                shortcut: 'Enter',
                action: (data) => this.playSong(data)
            },
            {
                icon: '➕',
                text: 'Add to Queue',
                shortcut: 'Q',
                action: (data) => this.addToQueue(data)
            },
            {
                icon: '⭐',
                text: currentRating ? `Rated ${currentRating}/5` : 'Rate Song',
                shortcut: 'R',
                action: (data) => this.rateSong(data)
            },
            {
                icon: '📝',
                text: currentNote ? `Edit Note: "${currentNote.substring(0, 20)}..."` : 'Add Note',
                shortcut: 'N',
                action: (data) => this.addNote(data)
            },
            {
                icon: '🏷️',
                text: 'Add Tags',
                shortcut: 'T',
                action: (data) => this.addTags(data)
            },
            {
                icon: isInWorkOrder ? '✅' : '📋',
                text: isInWorkOrder ? 'Remove from Work Order' : 'Add to Work Order',
                shortcut: 'W',
                action: (data) => this.toggleWorkOrder(data)
            },
            {
                icon: '🚀',
                text: 'Add to Enhanced Work Order',
                shortcut: 'E',
                action: (data) => this.addToEnhancedWorkOrder(data)
            },
            {
                icon: '📊',
                text: 'View Details',
                shortcut: 'D',
                action: (data) => this.viewDetails(data)
            },
            {
                icon: '🔗',
                text: 'Copy Link',
                shortcut: 'C',
                action: (data) => this.copyLink(data)
            },
            {
                icon: '📤',
                text: 'Share Song',
                shortcut: 'S',
                action: (data) => this.shareSong(data)
            }
        ];
    }

    /**
     * Show context menu for album
     */
    showAlbumMenu(event, albumData) {
        event.preventDefault();
        this.currentTarget = albumData;
        
        this.menu.innerHTML = '';
        
        const menuItems = [
            {
                icon: '🎵',
                text: 'Play Album',
                action: (data) => this.playAlbum(data)
            },
            {
                icon: '➕',
                text: 'Add to Queue',
                action: (data) => this.addAlbumToQueue(data)
            },
            {
                icon: '📊',
                text: 'Album Statistics',
                action: (data) => this.showAlbumStats(data)
            },
            {
                icon: '🏷️',
                text: 'Tag Album',
                action: (data) => this.tagAlbum(data)
            },
            {
                icon: '📤',
                text: 'Share Album',
                action: (data) => this.shareAlbum(data)
            }
        ];
        
        menuItems.forEach(item => {
            const menuItem = document.createElement('div');
            menuItem.className = 'context-menu-item';
            menuItem.style.cssText = `
                padding: 12px 16px;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: 12px;
                transition: background-color 0.2s ease;
                border-bottom: 1px solid rgba(0, 0, 0, 0.1);
            `;
            
            menuItem.innerHTML = `
                <span style="font-size: 16px;">${item.icon}</span>
                <span>${item.text}</span>
            `;
            
            menuItem.addEventListener('click', (e) => {
                e.stopPropagation();
                item.action(albumData);
                this.hide();
            });
            
            menuItem.addEventListener('mouseenter', () => {
                menuItem.style.backgroundColor = 'rgba(102, 126, 234, 0.1)';
            });
            
            menuItem.addEventListener('mouseleave', () => {
                menuItem.style.backgroundColor = 'transparent';
            });
            
            this.menu.appendChild(menuItem);
        });
        
        this.positionMenu(event);
        this.show();
    }

    /**
     * Position the context menu
     */
    positionMenu(event) {
        const menu = this.menu;
        const rect = menu.getBoundingClientRect();
        const viewportWidth = window.innerWidth;
        const viewportHeight = window.innerHeight;
        
        let x = event.clientX;
        let y = event.clientY;
        
        // Adjust if menu would go off screen
        if (x + rect.width > viewportWidth) {
            x = viewportWidth - rect.width - 10;
        }
        
        if (y + rect.height > viewportHeight) {
            y = viewportHeight - rect.height - 10;
        }
        
        menu.style.left = `${x}px`;
        menu.style.top = `${y}px`;
    }

    /**
     * Show the context menu
     */
    show() {
        this.menu.style.display = 'block';
        this.menu.style.opacity = '0';
        this.menu.style.transform = 'scale(0.9)';
        
        // Animate in
        requestAnimationFrame(() => {
            this.menu.style.transition = 'all 0.2s ease';
            this.menu.style.opacity = '1';
            this.menu.style.transform = 'scale(1)';
        });
    }

    /**
     * Hide the context menu
     */
    hide() {
        if (this.menu.style.display !== 'none') {
            this.menu.style.transition = 'all 0.2s ease';
            this.menu.style.opacity = '0';
            this.menu.style.transform = 'scale(0.9)';
            
            setTimeout(() => {
                this.menu.style.display = 'none';
            }, 200);
        }
    }

    /**
     * Song menu actions
     */
    playSong(songData) {
        if (typeof playTrack === 'function') {
            playTrack(songData.album, songData.artist, songData.track, songData.duration, songData.cover, songData.trackIndex);
        }
    }

    addToQueue(songData) {
        if (typeof addToQueue === 'function') {
            addToQueue(songData);
        } else {
            // Fallback: add to a simple queue
            this.addToSimpleQueue(songData);
        }
    }

    rateSong(songData) {
        const songId = this.generateSongId(songData);
        const currentRating = this.getCurrentRating(songId);
        
        // Create rating dialog
        this.showRatingDialog(songData, currentRating);
    }

    addNote(songData) {
        const songId = this.generateSongId(songData);
        const currentNote = this.getCurrentNote(songId);
        
        // Create note dialog
        this.showNoteDialog(songData, currentNote);
    }

    addTags(songData) {
        const songId = this.generateSongId(songData);
        const currentTags = this.getCurrentTags(songId);
        
        // Create tags dialog
        this.showTagsDialog(songData, currentTags);
    }

    toggleWorkOrder(songData) {
        const songId = this.generateSongId(songData);
        const isInWorkOrder = this.isInWorkOrder(songId);
        
        if (isInWorkOrder) {
            this.removeFromWorkOrder(songId);
            this.showNotification('Removed from Work Order', 'success');
        } else {
            this.addToWorkOrder(songId, songData);
            this.showNotification('Added to Work Order', 'success');
        }
    }

    viewDetails(songData) {
        this.showSongDetails(songData);
    }

    copyLink(songData) {
        const link = this.generateSongLink(songData);
        navigator.clipboard.writeText(link).then(() => {
            this.showNotification('Link copied to clipboard', 'success');
        });
    }

    shareSong(songData) {
        this.showShareDialog(songData);
    }

    /**
     * Album menu actions
     */
    playAlbum(albumData) {
        if (typeof playAlbum === 'function') {
            playAlbum(albumData);
        }
    }

    addAlbumToQueue(albumData) {
        if (typeof addAlbumToQueue === 'function') {
            addAlbumToQueue(albumData);
        }
    }

    showAlbumStats(albumData) {
        this.showAlbumStatistics(albumData);
    }

    tagAlbum(albumData) {
        this.showAlbumTagsDialog(albumData);
    }

    shareAlbum(albumData) {
        this.showAlbumShareDialog(albumData);
    }

    /**
     * Dialog methods
     */
    showRatingDialog(songData, currentRating) {
        const dialog = document.createElement('div');
        dialog.className = 'rating-dialog';
        dialog.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            z-index: 10001;
            min-width: 300px;
        `;
        
        dialog.innerHTML = `
            <h3 style="margin: 0 0 15px 0; color: #333;">Rate "${songData.track}"</h3>
            <div class="rating-stars" style="display: flex; gap: 5px; margin-bottom: 15px;">
                ${[1, 2, 3, 4, 5].map(star => `
                    <span class="star" data-rating="${star}" style="font-size: 24px; cursor: pointer; color: ${star <= currentRating ? '#ffd700' : '#ddd'};">
                        ★
                    </span>
                `).join('')}
            </div>
            <div style="display: flex; gap: 10px; justify-content: flex-end;">
                <button class="btn-secondary" onclick="this.closest('.rating-dialog').remove()">Cancel</button>
                <button class="btn-primary" onclick="contextMenu.saveRating('${songData.track}', this.closest('.rating-dialog').querySelector('.star.selected')?.dataset.rating || 0)">Save</button>
            </div>
        `;
        
        document.body.appendChild(dialog);
        
        // Add star click handlers
        dialog.querySelectorAll('.star').forEach(star => {
            star.addEventListener('click', () => {
                const rating = parseInt(star.dataset.rating);
                dialog.querySelectorAll('.star').forEach(s => {
                    s.style.color = parseInt(s.dataset.rating) <= rating ? '#ffd700' : '#ddd';
                    s.classList.toggle('selected', parseInt(s.dataset.rating) === rating);
                });
            });
        });
    }

    showNoteDialog(songData, currentNote) {
        const dialog = document.createElement('div');
        dialog.className = 'note-dialog';
        dialog.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            z-index: 10001;
            min-width: 400px;
        `;
        
        dialog.innerHTML = `
            <h3 style="margin: 0 0 15px 0; color: #333;">Note for "${songData.track}"</h3>
            <textarea id="noteText" placeholder="Add your note here..." style="width: 100%; height: 100px; padding: 10px; border: 1px solid #ddd; border-radius: 8px; resize: vertical;">${currentNote || ''}</textarea>
            <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 15px;">
                <button class="btn-secondary" onclick="this.closest('.note-dialog').remove()">Cancel</button>
                <button class="btn-primary" onclick="contextMenu.saveNote('${songData.track}', document.getElementById('noteText').value)">Save</button>
            </div>
        `;
        
        document.body.appendChild(dialog);
    }

    showTagsDialog(songData, currentTags) {
        const dialog = document.createElement('div');
        dialog.className = 'tags-dialog';
        dialog.style.cssText = `
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
            z-index: 10001;
            min-width: 400px;
        `;
        
        dialog.innerHTML = `
            <h3 style="margin: 0 0 15px 0; color: #333;">Tags for "${songData.track}"</h3>
            <div class="current-tags" style="margin-bottom: 15px;">
                ${currentTags.map(tag => `
                    <span class="tag" style="display: inline-block; background: #667eea; color: white; padding: 4px 8px; border-radius: 12px; margin: 2px; font-size: 12px;">
                        ${tag} <span onclick="this.parentElement.remove()" style="cursor: pointer; margin-left: 5px;">×</span>
                    </span>
                `).join('')}
            </div>
            <input type="text" id="newTag" placeholder="Add new tag..." style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px;">
            <div style="display: flex; gap: 10px; justify-content: flex-end; margin-top: 15px;">
                <button class="btn-secondary" onclick="this.closest('.tags-dialog').remove()">Cancel</button>
                <button class="btn-primary" onclick="contextMenu.saveTags('${songData.track}', Array.from(this.closest('.tags-dialog').querySelectorAll('.tag')).map(t => t.textContent.split(' ×')[0]))">Save</button>
            </div>
        `;
        
        document.body.appendChild(dialog);
        
        // Add tag on Enter key
        dialog.querySelector('#newTag').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                const tag = e.target.value.trim();
                if (tag) {
                    const tagElement = document.createElement('span');
                    tagElement.className = 'tag';
                    tagElement.style.cssText = 'display: inline-block; background: #667eea; color: white; padding: 4px 8px; border-radius: 12px; margin: 2px; font-size: 12px;';
                    tagElement.innerHTML = `${tag} <span onclick="this.parentElement.remove()" style="cursor: pointer; margin-left: 5px;">×</span>`;
                    dialog.querySelector('.current-tags').appendChild(tagElement);
                    e.target.value = '';
                }
            }
        });
    }

    /**
     * Save methods
     */
    saveRating(trackName, rating) {
        const songId = this.generateSongId({ track: trackName });
        if (this.metadataManager) {
            this.metadataManager.setSongMetadata(songId, 'rating', parseInt(rating));
        }
        this.showNotification(`Rated ${trackName} ${rating}/5 stars`, 'success');
        document.querySelector('.rating-dialog').remove();
    }

    saveNote(trackName, note) {
        const songId = this.generateSongId({ track: trackName });
        if (this.metadataManager) {
            this.metadataManager.setSongMetadata(songId, 'note', note);
        }
        this.showNotification(`Note saved for ${trackName}`, 'success');
        document.querySelector('.note-dialog').remove();
    }

    saveTags(trackName, tags) {
        const songId = this.generateSongId({ track: trackName });
        if (this.metadataManager) {
            this.metadataManager.setSongMetadata(songId, 'tags', tags);
        }
        this.showNotification(`Tags saved for ${trackName}`, 'success');
        document.querySelector('.tags-dialog').remove();
    }

    /**
     * Utility methods
     */
    generateSongId(songData) {
        if (this.metadataManager) {
            return this.metadataManager.generateSongId(songData.track, songData.duration || 0, Date.now());
        }
        return btoa(`${songData.track}-${Date.now()}`).replace(/=/g, '');
    }

    getCurrentRating(songId) {
        if (this.metadataManager) {
            return this.metadataManager.getSongMetadata(songId).rating || 0;
        }
        return 0;
    }

    getCurrentNote(songId) {
        if (this.metadataManager) {
            return this.metadataManager.getSongMetadata(songId).note || '';
        }
        return '';
    }

    getCurrentTags(songId) {
        if (this.metadataManager) {
            return this.metadataManager.getSongMetadata(songId).tags || [];
        }
        return [];
    }

    isInWorkOrder(songId) {
        const workOrder = JSON.parse(localStorage.getItem('workOrder') || '[]');
        return workOrder.includes(songId);
    }

    addToWorkOrder(songId, songData) {
        const workOrder = JSON.parse(localStorage.getItem('workOrder') || '[]');
        if (!workOrder.includes(songId)) {
            workOrder.push(songId);
            localStorage.setItem('workOrder', JSON.stringify(workOrder));
        }
    }

    removeFromWorkOrder(songId) {
        const workOrder = JSON.parse(localStorage.getItem('workOrder') || '[]');
        const index = workOrder.indexOf(songId);
        if (index > -1) {
            workOrder.splice(index, 1);
            localStorage.setItem('workOrder', JSON.stringify(workOrder));
        }
    }

    // Enhanced Work Order functionality
    addToEnhancedWorkOrder(songData) {
        // Call the enhanced work order function from the main page
        if (typeof window.addToEnhancedWorkOrder === 'function') {
            window.addToEnhancedWorkOrder(songData);
        } else {
            // Fallback to basic work order
            this.toggleWorkOrder(songData);
        }
    }

    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#4CAF50' : type === 'error' ? '#f44336' : '#2196F3'};
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            z-index: 10002;
            font-size: 14px;
            max-width: 300px;
        `;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.transition = 'all 0.3s ease';
            notification.style.opacity = '0';
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }

    /**
     * Set metadata manager reference
     */
    setMetadataManager(metadataManager) {
        this.metadataManager = metadataManager;
    }

    /**
     * Set audio player reference
     */
    setAudioPlayer(audioPlayer) {
        this.audioPlayer = audioPlayer;
    }
}

// Global context menu instance
let contextMenu;

// Initialize context menu
function initializeContextMenu() {
    contextMenu = new ContextMenu();
    
    // Set references if available
    if (typeof metadataManager !== 'undefined') {
        contextMenu.setMetadataManager(metadataManager);
    }
    
    if (typeof audioPlayer !== 'undefined') {
        contextMenu.setAudioPlayer(audioPlayer);
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ContextMenu;
} else {
    window.ContextMenu = ContextMenu;
    window.initializeContextMenu = initializeContextMenu;
}
