/**
 * EchoVerse Persistent Audio System
 * Maintains audio playback across page navigation and provides background controls
 */

class PersistentAudio {
    constructor() {
        this.audioElement = null;
        this.currentTrack = null;
        this.isPlaying = false;
        this.volume = 0.7;
        this.position = 0;
        this.duration = 0;
        this.playlist = [];
        this.currentIndex = 0;
        this.audioContext = null;
        this.analyser = null;
        this.gainNode = null;
        this.bassFilter = null;
        this.trebleFilter = null;
        this.reverbNode = null;
        this.source = null;
        this.spectrumBars = [];
        this.animationId = null;
        this.notificationPermission = false;
        this.backgroundControls = null;
        this.initializeAudio();
        this.createBackgroundControls();
        this.setupEventListeners();
        this.loadPersistentState();
    }

    /**
     * Initialize audio system
     */
    initializeAudio() {
        // Create audio element
        this.audioElement = document.createElement('audio');
        this.audioElement.crossOrigin = 'anonymous';
        this.audioElement.preload = 'metadata';
        this.audioElement.volume = this.volume;
        
        // Initialize Web Audio API
        this.initializeWebAudio();
        
        // Add to document
        document.body.appendChild(this.audioElement);
    }

    /**
     * Initialize Web Audio API
     */
    initializeWebAudio() {
        try {
            this.audioContext = new (window.AudioContext || window.webkitAudioContext)();
            this.analyser = this.audioContext.createAnalyser();
            this.gainNode = this.audioContext.createGain();
            this.bassFilter = this.audioContext.createBiquadFilter();
            this.trebleFilter = this.audioContext.createBiquadFilter();
            this.reverbNode = this.audioContext.createConvolver();
            
            // Configure analyser
            this.analyser.fftSize = 256;
            this.analyser.smoothingTimeConstant = 0.8;
            
            // Configure filters
            this.bassFilter.type = 'lowshelf';
            this.bassFilter.frequency.setValueAtTime(250, this.audioContext.currentTime);
            this.bassFilter.gain.setValueAtTime(0, this.audioContext.currentTime);
            
            this.trebleFilter.type = 'highshelf';
            this.trebleFilter.frequency.setValueAtTime(4000, this.audioContext.currentTime);
            this.trebleFilter.gain.setValueAtTime(0, this.audioContext.currentTime);
            
            // Create reverb impulse
            this.createReverbImpulse();
            
            // Connect audio graph
            this.connectAudioGraph();
            
        } catch (error) {
            console.error('Web Audio API not supported:', error);
        }
    }

    /**
     * Create reverb impulse response
     */
    createReverbImpulse() {
        const length = this.audioContext.sampleRate * 2;
        const impulse = this.audioContext.createBuffer(2, length, this.audioContext.sampleRate);
        
        for (let channel = 0; channel < 2; channel++) {
            const channelData = impulse.getChannelData(channel);
            for (let i = 0; i < length; i++) {
                channelData[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / length, 2);
            }
        }
        
        this.reverbNode.buffer = impulse;
    }

    /**
     * Connect audio graph
     */
    connectAudioGraph() {
        if (this.audioContext && this.analyser) {
            this.audioElement.connect(this.analyser);
            this.analyser.connect(this.gainNode);
            this.gainNode.connect(this.bassFilter);
            this.bassFilter.connect(this.trebleFilter);
            this.trebleFilter.connect(this.reverbNode);
            this.reverbNode.connect(this.audioContext.destination);
        }
    }

    /**
     * Create background controls
     */
    createBackgroundControls() {
        this.backgroundControls = document.createElement('div');
        this.backgroundControls.id = 'persistentAudioControls';
        this.backgroundControls.style.cssText = `
            position: fixed;
            bottom: 20px;
            left: 20px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            z-index: 1000;
            min-width: 300px;
            display: none;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        `;
        
        this.backgroundControls.innerHTML = `
            <div style="display: flex; align-items: center; gap: 15px;">
                <div class="track-info" style="flex: 1; min-width: 0;">
                    <div class="track-title" style="font-weight: 600; color: #333; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">No track</div>
                    <div class="track-artist" style="font-size: 12px; color: #666; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">No artist</div>
                </div>
                <div class="controls" style="display: flex; align-items: center; gap: 10px;">
                    <button class="prev-btn" style="background: none; border: none; font-size: 18px; cursor: pointer; color: #333;">⏮️</button>
                    <button class="play-pause-btn" style="background: none; border: none; font-size: 24px; cursor: pointer; color: #333;">▶️</button>
                    <button class="next-btn" style="background: none; border: none; font-size: 18px; cursor: pointer; color: #333;">⏭️</button>
                    <button class="close-btn" style="background: none; border: none; font-size: 16px; cursor: pointer; color: #666;">✕</button>
                </div>
            </div>
            <div class="progress-container" style="margin-top: 10px;">
                <div class="progress-bar" style="width: 100%; height: 4px; background: #ddd; border-radius: 2px; cursor: pointer;">
                    <div class="progress-fill" style="height: 100%; background: #667eea; border-radius: 2px; width: 0%; transition: width 0.1s ease;"></div>
                </div>
                <div class="time-display" style="display: flex; justify-content: space-between; font-size: 11px; color: #666; margin-top: 5px;">
                    <span class="current-time">0:00</span>
                    <span class="total-time">0:00</span>
                </div>
            </div>
            <div class="spectrum-analyzer" style="margin-top: 10px; height: 20px; display: flex; align-items: end; justify-content: center; gap: 1px; opacity: 0.7;"></div>
        `;
        
        document.body.appendChild(this.backgroundControls);
        this.attachControlListeners();
    }

    /**
     * Attach control listeners
     */
    attachControlListeners() {
        const playPauseBtn = this.backgroundControls.querySelector('.play-pause-btn');
        const prevBtn = this.backgroundControls.querySelector('.prev-btn');
        const nextBtn = this.backgroundControls.querySelector('.next-btn');
        const closeBtn = this.backgroundControls.querySelector('.close-btn');
        const progressBar = this.backgroundControls.querySelector('.progress-bar');
        
        playPauseBtn.addEventListener('click', () => this.togglePlayPause());
        prevBtn.addEventListener('click', () => this.playPrevious());
        nextBtn.addEventListener('click', () => this.playNext());
        closeBtn.addEventListener('click', () => this.hideControls());
        
        progressBar.addEventListener('click', (e) => {
            const rect = progressBar.getBoundingClientRect();
            const clickX = e.clientX - rect.left;
            const percentage = clickX / rect.width;
            this.seekTo(percentage);
        });
    }

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Audio element events
        this.audioElement.addEventListener('play', () => {
            this.isPlaying = true;
            this.updatePlayButton();
            this.startSpectrumAnalyzer();
            this.showControls();
        });
        
        this.audioElement.addEventListener('pause', () => {
            this.isPlaying = false;
            this.updatePlayButton();
            this.stopSpectrumAnalyzer();
        });
        
        this.audioElement.addEventListener('ended', () => {
            this.playNext();
        });
        
        this.audioElement.addEventListener('timeupdate', () => {
            this.updateProgress();
        });
        
        this.audioElement.addEventListener('loadedmetadata', () => {
            this.duration = this.audioElement.duration;
            this.updateTimeDisplay();
        });
        
        // Page visibility events
        document.addEventListener('visibilitychange', () => {
            if (document.hidden && this.isPlaying) {
                this.showNotification('Music continues in background');
            }
        });
        
        // Before unload - save state
        window.addEventListener('beforeunload', () => {
            this.savePersistentState();
        });
        
        // Page load - restore state
        window.addEventListener('load', () => {
            this.restorePersistentState();
        });
    }

    /**
     * Play a track with enhanced error handling
     */
    playTrack(trackData) {
        console.log('🎵 Persistent Audio: Playing track:', trackData.track, 'by', trackData.artist);
        
        this.currentTrack = trackData;
        const audioUrl = trackData.src || `file:///M:/Albums/${trackData.album}/${trackData.track}.mp3`;
        
        console.log('🔗 Persistent Audio URL:', audioUrl);
        
        // Show loading state
        this.showLoadingState();
        
        this.audioElement.src = audioUrl;
        this.audioElement.load();
        
        // Update display
        this.updateTrackInfo();
        this.showControls();
        
        // Try to play with enhanced error handling
        const playPromise = this.audioElement.play();
        if (playPromise !== undefined) {
            playPromise.then(() => {
                this.isPlaying = true;
                this.updatePlayButton();
                this.startSpectrumAnalyzer();
                this.hideLoadingState();
                console.log('✅ Persistent Audio: Playback started successfully');
                this.showNotification(`Now playing: ${trackData.track}`, 'success');
            }).catch(error => {
                console.error('❌ Persistent Audio: Could not play audio:', error);
                this.handlePlaybackError(error, trackData);
            });
        }
    }
    
    /**
     * Handle playback errors with fallback methods
     */
    handlePlaybackError(error, trackData) {
        console.log('🔄 Persistent Audio: Attempting fallback methods...');
        
        // Try different URL formats
        const fallbackUrls = this.generateFallbackUrls(trackData);
        
        if (fallbackUrls.length > 0) {
            this.tryFallbackUrls(fallbackUrls, 0, trackData);
        } else {
            this.showNotification(`Cannot play ${trackData.track}. All methods failed.`, 'error');
            this.hideLoadingState();
        }
    }
    
    /**
     * Generate fallback URLs for different access methods
     */
    generateFallbackUrls(trackData) {
        const urls = [];
        const originalUrl = trackData.src;
        
        // If it's already an API URL, try direct file access
        if (originalUrl && originalUrl.includes('/api/audio/')) {
            const filePath = decodeURIComponent(originalUrl.split('/api/audio/')[1]);
            urls.push(filePath);
        }
        
        // Try different API endpoints
        if (originalUrl && !originalUrl.includes('/api/audio/')) {
            const encodedPath = encodeURIComponent(originalUrl);
            urls.push(`/api/audio/${encodedPath}?use_tailscale=true`);
            urls.push(`/api/audio/${encodedPath}?use_tailscale=false`);
        }
        
        return urls;
    }
    
    /**
     * Try fallback URLs recursively
     */
    tryFallbackUrls(urls, index, trackData) {
        if (index >= urls.length) {
            this.showNotification(`Cannot play ${trackData.track}. All methods failed.`, 'error');
            this.hideLoadingState();
            return;
        }
        
        const url = urls[index];
        console.log(`🔄 Persistent Audio: Trying fallback ${index + 1}/${urls.length}:`, url);
        
        this.audioElement.src = url;
        this.audioElement.load();
        
        const playPromise = this.audioElement.play();
        if (playPromise !== undefined) {
            playPromise.then(() => {
                this.isPlaying = true;
                this.updatePlayButton();
                this.startSpectrumAnalyzer();
                this.hideLoadingState();
                console.log(`✅ Persistent Audio: Fallback ${index + 1} successful`);
                this.showNotification(`Now playing: ${trackData.track}`, 'success');
            }).catch(error => {
                console.error(`❌ Persistent Audio: Fallback ${index + 1} failed:`, error);
                this.tryFallbackUrls(urls, index + 1, trackData);
            });
        }
    }
    
    /**
     * Show loading state
     */
    showLoadingState() {
        const trackTitle = this.backgroundControls.querySelector('.track-title');
        if (trackTitle) {
            trackTitle.textContent = `⏳ Loading ${this.currentTrack?.track || 'track'}...`;
            trackTitle.style.color = '#8a5fff';
        }
    }
    
    /**
     * Hide loading state
     */
    hideLoadingState() {
        const trackTitle = this.backgroundControls.querySelector('.track-title');
        if (trackTitle) {
            trackTitle.style.color = '';
        }
    }

    /**
     * Toggle play/pause
     */
    togglePlayPause() {
        if (this.isPlaying) {
            this.audioElement.pause();
        } else {
            this.audioElement.play().then(() => {
                this.isPlaying = true;
                this.updatePlayButton();
                this.startSpectrumAnalyzer();
            }).catch(error => {
                console.log('Could not play audio:', error);
            });
        }
    }

    /**
     * Play next track
     */
    playNext() {
        if (this.playlist.length > 0) {
            this.currentIndex = (this.currentIndex + 1) % this.playlist.length;
            this.playTrack(this.playlist[this.currentIndex]);
        }
    }

    /**
     * Play previous track
     */
    playPrevious() {
        if (this.playlist.length > 0) {
            this.currentIndex = this.currentIndex > 0 ? this.currentIndex - 1 : this.playlist.length - 1;
            this.playTrack(this.playlist[this.currentIndex]);
        }
    }

    /**
     * Seek to position
     */
    seekTo(percentage) {
        if (this.duration > 0) {
            this.audioElement.currentTime = this.duration * percentage;
        }
    }

    /**
     * Update progress bar
     */
    updateProgress() {
        if (this.duration > 0) {
            const percentage = (this.audioElement.currentTime / this.duration) * 100;
            const progressFill = this.backgroundControls.querySelector('.progress-fill');
            if (progressFill) {
                progressFill.style.width = `${percentage}%`;
            }
            this.updateTimeDisplay();
        }
    }

    /**
     * Update time display
     */
    updateTimeDisplay() {
        const currentTime = this.backgroundControls.querySelector('.current-time');
        const totalTime = this.backgroundControls.querySelector('.total-time');
        
        if (currentTime) {
            currentTime.textContent = this.formatTime(this.audioElement.currentTime);
        }
        
        if (totalTime) {
            totalTime.textContent = this.formatTime(this.duration);
        }
    }

    /**
     * Format time
     */
    formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }

    /**
     * Update track info
     */
    updateTrackInfo() {
        const trackTitle = this.backgroundControls.querySelector('.track-title');
        const trackArtist = this.backgroundControls.querySelector('.track-artist');
        
        if (trackTitle && this.currentTrack) {
            trackTitle.textContent = this.currentTrack.track || 'Unknown Track';
        }
        
        if (trackArtist && this.currentTrack) {
            trackArtist.textContent = `${this.currentTrack.artist || 'Unknown Artist'} - ${this.currentTrack.album || 'Unknown Album'}`;
        }
    }

    /**
     * Update play button
     */
    updatePlayButton() {
        const playPauseBtn = this.backgroundControls.querySelector('.play-pause-btn');
        if (playPauseBtn) {
            playPauseBtn.textContent = this.isPlaying ? '⏸️' : '▶️';
        }
    }

    /**
     * Show controls
     */
    showControls() {
        this.backgroundControls.style.display = 'block';
    }

    /**
     * Hide controls
     */
    hideControls() {
        this.backgroundControls.style.display = 'none';
    }

    /**
     * Start spectrum analyzer
     */
    startSpectrumAnalyzer() {
        if (!this.analyser) return;
        
        const spectrumContainer = this.backgroundControls.querySelector('.spectrum-analyzer');
        if (!spectrumContainer) return;
        
        // Clear existing bars
        spectrumContainer.innerHTML = '';
        this.spectrumBars = [];
        
        // Create spectrum bars
        const barCount = 32;
        for (let i = 0; i < barCount; i++) {
            const bar = document.createElement('div');
            bar.style.cssText = `
                width: 3px;
                background: linear-gradient(to top, #667eea, #764ba2);
                border-radius: 1px;
                transition: height 0.1s ease;
            `;
            spectrumContainer.appendChild(bar);
            this.spectrumBars.push(bar);
        }
        
        // Start animation
        this.animateSpectrum();
    }

    /**
     * Stop spectrum analyzer
     */
    stopSpectrumAnalyzer() {
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
            this.animationId = null;
        }
    }

    /**
     * Animate spectrum analyzer
     */
    animateSpectrum() {
        if (!this.analyser || !this.isPlaying) return;
        
        const bufferLength = this.analyser.frequencyBinCount;
        const dataArray = new Uint8Array(bufferLength);
        this.analyser.getByteFrequencyData(dataArray);
        
        // Update spectrum bars
        this.spectrumBars.forEach((bar, index) => {
            const value = dataArray[Math.floor(index * bufferLength / this.spectrumBars.length)];
            const height = Math.max(2, (value / 255) * 20);
            bar.style.height = `${height}px`;
        });
        
        this.animationId = requestAnimationFrame(() => this.animateSpectrum());
    }

    /**
     * Show notification
     */
    showNotification(message, type = 'info') {
        if (!this.notificationPermission) {
            this.requestNotificationPermission();
        }
        
        // Create visual notification
        const notification = document.createElement('div');
        notification.className = `audio-notification`;
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
            animation: slideIn 0.3s ease;
        `;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
        
        // Browser notification if permission granted
        if (this.notificationPermission && 'Notification' in window) {
            new Notification('EchoVerse Audio', {
                body: message,
                icon: '/favicon.ico'
            });
        }
    }

    /**
     * Request notification permission
     */
    async requestNotificationPermission() {
        if ('Notification' in window && Notification.permission === 'default') {
            this.notificationPermission = await Notification.requestPermission() === 'granted';
        }
    }

    /**
     * Save persistent state
     */
    savePersistentState() {
        const state = {
            currentTrack: this.currentTrack,
            isPlaying: this.isPlaying,
            volume: this.volume,
            position: this.audioElement.currentTime,
            playlist: this.playlist,
            currentIndex: this.currentIndex
        };
        
        localStorage.setItem('persistentAudioState', JSON.stringify(state));
    }

    /**
     * Load persistent state
     */
    loadPersistentState() {
        try {
            const saved = localStorage.getItem('persistentAudioState');
            if (saved) {
                const state = JSON.parse(saved);
                this.volume = state.volume || 0.7;
                this.playlist = state.playlist || [];
                this.currentIndex = state.currentIndex || 0;
                this.audioElement.volume = this.volume;
                
                if (state.currentTrack) {
                    this.currentTrack = state.currentTrack;
                    this.updateTrackInfo();
                }
            }
        } catch (error) {
            console.error('Error loading persistent state:', error);
        }
    }

    /**
     * Restore persistent state
     */
    restorePersistentState() {
        try {
            const saved = localStorage.getItem('persistentAudioState');
            if (saved) {
                const state = JSON.parse(saved);
                
                if (state.currentTrack && state.isPlaying) {
                    this.playTrack(state.currentTrack);
                    if (state.position) {
                        this.audioElement.currentTime = state.position;
                    }
                }
            }
        } catch (error) {
            console.error('Error restoring persistent state:', error);
        }
    }

    /**
     * Add track to playlist
     */
    addToPlaylist(trackData) {
        this.playlist.push(trackData);
        this.savePersistentState();
    }

    /**
     * Remove track from playlist
     */
    removeFromPlaylist(index) {
        this.playlist.splice(index, 1);
        if (this.currentIndex >= index) {
            this.currentIndex = Math.max(0, this.currentIndex - 1);
        }
        this.savePersistentState();
    }

    /**
     * Clear playlist
     */
    clearPlaylist() {
        this.playlist = [];
        this.currentIndex = 0;
        this.savePersistentState();
    }

    /**
     * Get current track info
     */
    getCurrentTrack() {
        return this.currentTrack;
    }

    /**
     * Get playlist
     */
    getPlaylist() {
        return this.playlist;
    }

    /**
     * Set volume
     */
    setVolume(volume) {
        this.volume = Math.max(0, Math.min(1, volume));
        this.audioElement.volume = this.volume;
        this.savePersistentState();
    }

    /**
     * Get volume
     */
    getVolume() {
        return this.volume;
    }

    /**
     * Set audio effects
     */
    setBass(value) {
        if (this.bassFilter) {
            this.bassFilter.gain.setValueAtTime(value, this.audioContext.currentTime);
        }
    }

    setTreble(value) {
        if (this.trebleFilter) {
            this.trebleFilter.gain.setValueAtTime(value, this.audioContext.currentTime);
        }
    }

    setReverb(value) {
        if (this.reverbNode) {
            this.reverbNode.gain = value;
        }
    }
}

// Global persistent audio instance
let persistentAudio;

// Initialize persistent audio
function initializePersistentAudio() {
    persistentAudio = new PersistentAudio();
}

// Global functions for integration
function playTrackPersistent(trackData) {
    if (persistentAudio) {
        persistentAudio.playTrack(trackData);
    }
}

function addToPlaylist(trackData) {
    if (persistentAudio) {
        persistentAudio.addToPlaylist(trackData);
    }
}

function togglePlayPausePersistent() {
    if (persistentAudio) {
        persistentAudio.togglePlayPause();
    }
}

function playNextPersistent() {
    if (persistentAudio) {
        persistentAudio.playNext();
    }
}

function playPreviousPersistent() {
    if (persistentAudio) {
        persistentAudio.playPrevious();
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PersistentAudio;
} else {
    window.PersistentAudio = PersistentAudio;
    window.initializePersistentAudio = initializePersistentAudio;
    window.playTrackPersistent = playTrackPersistent;
    window.addToPlaylist = addToPlaylist;
    window.togglePlayPausePersistent = togglePlayPausePersistent;
    window.playNextPersistent = playNextPersistent;
    window.playPreviousPersistent = playPreviousPersistent;
}
