/**
 * EchoVerse Theme Integration System
 * Integrates custom themes with existing catalog interfaces
 */

class ThemeIntegration {
    constructor() {
        this.currentTheme = null;
        this.loadSavedTheme();
        this.applyThemeToDocument();
    }

    /**
     * Load saved theme from localStorage
     */
    loadSavedTheme() {
        try {
            const saved = localStorage.getItem('echoverse_theme');
            if (saved) {
                this.currentTheme = JSON.parse(saved);
            } else {
                this.loadDefaultTheme();
            }
        } catch (error) {
            console.error('Error loading theme:', error);
            this.loadDefaultTheme();
        }
    }

    /**
     * Load default theme
     */
    loadDefaultTheme() {
        this.currentTheme = {
            background: {
                colors: ['#0f0f23', '#1a1a2e', '#16213e'],
                gradient: true,
                direction: '135deg'
            },
            card: {
                colors: ['#ffffff', '#ffffff', '#ffffff'],
                gradient: false,
                direction: '135deg'
            },
            text: {
                normal: '#ffffff',
                highlight: '#667eea',
                selected: '#667eea'
            },
            button: {
                colors: ['#667eea', '#764ba2'],
                text: '#ffffff',
                gradient: true,
                direction: '135deg'
            }
        };
    }

    /**
     * Apply theme to document
     */
    applyThemeToDocument() {
        if (!this.currentTheme) return;

        const root = document.documentElement;
        
        // Apply background theme
        if (this.currentTheme.background.gradient) {
            const bg = `linear-gradient(${this.currentTheme.background.direction}, ${this.currentTheme.background.colors.join(', ')})`;
            root.style.setProperty('--theme-bg', bg);
        } else {
            root.style.setProperty('--theme-bg', this.currentTheme.background.colors[0]);
        }
        
        // Apply card theme
        if (this.currentTheme.card.gradient) {
            const card = `linear-gradient(${this.currentTheme.card.direction}, ${this.currentTheme.card.colors.join(', ')})`;
            root.style.setProperty('--theme-card-bg', card);
        } else {
            root.style.setProperty('--theme-card-bg', this.currentTheme.card.colors[0]);
        }
        
        // Apply text theme
        root.style.setProperty('--theme-text', this.currentTheme.text.normal);
        root.style.setProperty('--theme-highlight', this.currentTheme.text.highlight);
        root.style.setProperty('--theme-selected-text', this.currentTheme.text.selected);
        
        // Apply button theme
        if (this.currentTheme.button.gradient) {
            const button = `linear-gradient(${this.currentTheme.button.direction}, ${this.currentTheme.button.colors.join(', ')})`;
            root.style.setProperty('--theme-button-bg', button);
        } else {
            root.style.setProperty('--theme-button-bg', this.currentTheme.button.colors[0]);
        }
        root.style.setProperty('--theme-button-text', this.currentTheme.button.text);
        
        // Apply theme to body
        document.body.style.background = `var(--theme-bg)`;
        document.body.style.color = `var(--theme-text)`;
        
        // Update existing elements
        this.updateExistingElements();
    }

    /**
     * Update existing elements with theme
     */
    updateExistingElements() {
        // Update album cards
        const albumCards = document.querySelectorAll('.album-card');
        albumCards.forEach(card => {
            card.style.background = `var(--theme-card-bg)`;
            card.style.color = `var(--theme-text)`;
        });

        // Update buttons
        const buttons = document.querySelectorAll('.btn');
        buttons.forEach(button => {
            button.style.background = `var(--theme-button-bg)`;
            button.style.color = `var(--theme-button-text)`;
        });

        // Update headers
        const headers = document.querySelectorAll('.header');
        headers.forEach(header => {
            header.style.background = `var(--theme-card-bg)`;
        });

        // Update stat cards
        const statCards = document.querySelectorAll('.stat-card');
        statCards.forEach(card => {
            card.style.background = `var(--theme-card-bg)`;
        });

        // Update search sections
        const searchSections = document.querySelectorAll('.search-filter-section');
        searchSections.forEach(section => {
            section.style.background = `var(--theme-card-bg)`;
        });
    }

    /**
     * Get current theme
     */
    getCurrentTheme() {
        return this.currentTheme;
    }

    /**
     * Set theme
     */
    setTheme(theme) {
        this.currentTheme = theme;
        this.applyThemeToDocument();
        this.saveTheme();
    }

    /**
     * Save theme to localStorage
     */
    saveTheme() {
        try {
            localStorage.setItem('echoverse_theme', JSON.stringify(this.currentTheme));
        } catch (error) {
            console.error('Error saving theme:', error);
        }
    }

    /**
     * Export theme
     */
    exportTheme() {
        const themeData = {
            name: 'EchoVerse Custom Theme',
            version: '1.0',
            theme: this.currentTheme,
            exported: new Date().toISOString()
        };
        
        const blob = new Blob([JSON.stringify(themeData, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'echoverse-theme.json';
        a.click();
        URL.revokeObjectURL(url);
    }

    /**
     * Import theme
     */
    importTheme(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = (e) => {
                try {
                    const themeData = JSON.parse(e.target.result);
                    if (themeData.theme) {
                        this.setTheme(themeData.theme);
                        resolve(themeData);
                    } else {
                        reject(new Error('Invalid theme file format'));
                    }
                } catch (error) {
                    reject(error);
                }
            };
            reader.readAsText(file);
        });
    }

    /**
     * Reset to default theme
     */
    resetTheme() {
        this.loadDefaultTheme();
        this.applyThemeToDocument();
        this.saveTheme();
    }

    /**
     * Get theme CSS variables
     */
    getThemeCSS() {
        return `
            :root {
                --theme-bg: ${this.currentTheme.background.gradient ? 
                    `linear-gradient(${this.currentTheme.background.direction}, ${this.currentTheme.background.colors.join(', ')})` :
                    this.currentTheme.background.colors[0]};
                --theme-card-bg: ${this.currentTheme.card.gradient ? 
                    `linear-gradient(${this.currentTheme.card.direction}, ${this.currentTheme.card.colors.join(', ')})` :
                    this.currentTheme.card.colors[0]};
                --theme-text: ${this.currentTheme.text.normal};
                --theme-highlight: ${this.currentTheme.text.highlight};
                --theme-selected-text: ${this.currentTheme.text.selected};
                --theme-button-bg: ${this.currentTheme.button.gradient ? 
                    `linear-gradient(${this.currentTheme.button.direction}, ${this.currentTheme.button.colors.join(', ')})` :
                    this.currentTheme.button.colors[0]};
                --theme-button-text: ${this.currentTheme.button.text};
            }
        `;
    }

    /**
     * Create theme selector UI
     */
    createThemeSelector() {
        const themeSelector = document.createElement('div');
        themeSelector.className = 'theme-selector';
        themeSelector.innerHTML = `
            <div class="theme-selector-content">
                <button class="theme-toggle-btn" onclick="toggleThemeSelector()">
                    🎨 Theme
                </button>
                <div class="theme-selector-panel" id="themeSelectorPanel">
                    <div class="theme-actions">
                        <button class="btn" onclick="openThemeCustomizer()">Customize</button>
                        <button class="btn secondary" onclick="exportCurrentTheme()">Export</button>
                        <button class="btn secondary" onclick="importThemeFile()">Import</button>
                        <button class="btn secondary" onclick="resetCurrentTheme()">Reset</button>
                    </div>
                    <div class="preset-themes">
                        <h4>Preset Themes</h4>
                        <div class="preset-grid">
                            <div class="preset-item" onclick="loadPresetTheme('default')">
                                <div class="preset-preview" style="background: linear-gradient(135deg, #0f0f23 0%, #1a1a2e 50%, #16213e 100%);"></div>
                                <span>Default</span>
                            </div>
                            <div class="preset-item" onclick="loadPresetTheme('ocean')">
                                <div class="preset-preview" style="background: linear-gradient(135deg, #0c4a6e 0%, #0369a1 50%, #0284c7 100%);"></div>
                                <span>Ocean</span>
                            </div>
                            <div class="preset-item" onclick="loadPresetTheme('sunset')">
                                <div class="preset-preview" style="background: linear-gradient(135deg, #7c2d12 0%, #ea580c 50%, #f97316 100%);"></div>
                                <span>Sunset</span>
                            </div>
                            <div class="preset-item" onclick="loadPresetTheme('forest')">
                                <div class="preset-preview" style="background: linear-gradient(135deg, #14532d 0%, #16a34a 50%, #22c55e 100%);"></div>
                                <span>Forest</span>
                            </div>
                            <div class="preset-item" onclick="loadPresetTheme('purple')">
                                <div class="preset-preview" style="background: linear-gradient(135deg, #581c87 0%, #7c3aed 50%, #a855f7 100%);"></div>
                                <span>Purple</span>
                            </div>
                            <div class="preset-item" onclick="loadPresetTheme('minimal')">
                                <div class="preset-preview" style="background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 50%, #cbd5e1 100%);"></div>
                                <span>Minimal</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        // Add styles
        const style = document.createElement('style');
        style.textContent = `
            .theme-selector {
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 1000;
            }
            
            .theme-selector-content {
                position: relative;
            }
            
            .theme-toggle-btn {
                background: var(--theme-button-bg);
                color: var(--theme-button-text);
                border: none;
                padding: 10px 15px;
                border-radius: 20px;
                cursor: pointer;
                font-weight: 500;
                transition: transform 0.2s ease;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
            }
            
            .theme-toggle-btn:hover {
                transform: translateY(-2px);
            }
            
            .theme-selector-panel {
                position: absolute;
                top: 100%;
                right: 0;
                background: var(--theme-card-bg);
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 15px;
                padding: 20px;
                min-width: 300px;
                display: none;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
                backdrop-filter: blur(20px);
            }
            
            .theme-selector-panel.active {
                display: block;
            }
            
            .theme-actions {
                display: flex;
                gap: 10px;
                margin-bottom: 20px;
                flex-wrap: wrap;
            }
            
            .theme-actions .btn {
                flex: 1;
                min-width: 80px;
                font-size: 0.9rem;
                padding: 8px 12px;
            }
            
            .preset-themes h4 {
                color: var(--theme-text);
                margin-bottom: 15px;
                font-size: 1rem;
            }
            
            .preset-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 10px;
            }
            
            .preset-item {
                background: var(--theme-card-bg);
                border: 1px solid rgba(255, 255, 255, 0.1);
                border-radius: 8px;
                padding: 10px;
                cursor: pointer;
                transition: transform 0.2s ease;
                text-align: center;
            }
            
            .preset-item:hover {
                transform: translateY(-2px);
            }
            
            .preset-preview {
                width: 100%;
                height: 30px;
                border-radius: 5px;
                margin-bottom: 5px;
            }
            
            .preset-item span {
                font-size: 0.8rem;
                color: var(--theme-text);
            }
        `;
        
        document.head.appendChild(style);
        return themeSelector;
    }

    /**
     * Add theme selector to page
     */
    addThemeSelector() {
        const themeSelector = this.createThemeSelector();
        document.body.appendChild(themeSelector);
    }
}

// Preset themes
const presetThemes = {
    default: {
        background: { colors: ['#0f0f23', '#1a1a2e', '#16213e'], gradient: true, direction: '135deg' },
        card: { colors: ['#ffffff', '#ffffff', '#ffffff'], gradient: false, direction: '135deg' },
        text: { normal: '#ffffff', highlight: '#667eea', selected: '#667eea' },
        button: { colors: ['#667eea', '#764ba2'], text: '#ffffff', gradient: true, direction: '135deg' }
    },
    ocean: {
        background: { colors: ['#0c4a6e', '#0369a1', '#0284c7'], gradient: true, direction: '135deg' },
        card: { colors: ['#ffffff', '#f0f9ff', '#e0f2fe'], gradient: true, direction: '135deg' },
        text: { normal: '#ffffff', highlight: '#0ea5e9', selected: '#0284c7' },
        button: { colors: ['#0ea5e9', '#0284c7'], text: '#ffffff', gradient: true, direction: '135deg' }
    },
    sunset: {
        background: { colors: ['#7c2d12', '#ea580c', '#f97316'], gradient: true, direction: '135deg' },
        card: { colors: ['#ffffff', '#fef3c7', '#fed7aa'], gradient: true, direction: '135deg' },
        text: { normal: '#ffffff', highlight: '#f97316', selected: '#ea580c' },
        button: { colors: ['#f97316', '#ea580c'], text: '#ffffff', gradient: true, direction: '135deg' }
    },
    forest: {
        background: { colors: ['#14532d', '#16a34a', '#22c55e'], gradient: true, direction: '135deg' },
        card: { colors: ['#ffffff', '#f0fdf4', '#dcfce7'], gradient: true, direction: '135deg' },
        text: { normal: '#ffffff', highlight: '#22c55e', selected: '#16a34a' },
        button: { colors: ['#22c55e', '#16a34a'], text: '#ffffff', gradient: true, direction: '135deg' }
    },
    purple: {
        background: { colors: ['#581c87', '#7c3aed', '#a855f7'], gradient: true, direction: '135deg' },
        card: { colors: ['#ffffff', '#faf5ff', '#f3e8ff'], gradient: true, direction: '135deg' },
        text: { normal: '#ffffff', highlight: '#a855f7', selected: '#7c3aed' },
        button: { colors: ['#a855f7', '#7c3aed'], text: '#ffffff', gradient: true, direction: '135deg' }
    },
    minimal: {
        background: { colors: ['#f8fafc', '#e2e8f0', '#cbd5e1'], gradient: true, direction: '135deg' },
        card: { colors: ['#ffffff', '#f8fafc', '#f1f5f9'], gradient: true, direction: '135deg' },
        text: { normal: '#1e293b', highlight: '#3b82f6', selected: '#1d4ed8' },
        button: { colors: ['#3b82f6', '#1d4ed8'], text: '#ffffff', gradient: true, direction: '135deg' }
    }
};

// Global theme integration instance
let themeIntegration;

// Global functions for theme integration
function toggleThemeSelector() {
    const panel = document.getElementById('themeSelectorPanel');
    if (panel) {
        panel.classList.toggle('active');
    }
}

function openThemeCustomizer() {
    window.open('theme_customizer.html', '_blank');
}

function exportCurrentTheme() {
    if (themeIntegration) {
        themeIntegration.exportTheme();
    }
}

function importThemeFile() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.onchange = (e) => {
        const file = e.target.files[0];
        if (file && themeIntegration) {
            themeIntegration.importTheme(file).then(() => {
                alert('Theme imported successfully!');
                location.reload();
            }).catch(error => {
                alert('Error importing theme: ' + error.message);
            });
        }
    };
    input.click();
}

function resetCurrentTheme() {
    if (themeIntegration) {
        themeIntegration.resetTheme();
        location.reload();
    }
}

function loadPresetTheme(presetName) {
    if (presetThemes[presetName] && themeIntegration) {
        themeIntegration.setTheme(presetThemes[presetName]);
        location.reload();
    }
}

// Initialize theme integration
function initializeThemeIntegration() {
    themeIntegration = new ThemeIntegration();
    themeIntegration.addThemeSelector();
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ThemeIntegration;
} else {
    window.ThemeIntegration = ThemeIntegration;
    window.initializeThemeIntegration = initializeThemeIntegration;
}
