# EchoVerse Music Catalog - Tailscale Streaming Guide

## Overview

This guide explains how the EchoVerse Music Catalog uses Tailscale for secure remote audio streaming. Tailscale provides a secure, encrypted network connection that allows you to access your music catalog from anywhere without exposing your server to the public internet.

## Tailscale Configuration

The EchoVerse Music Catalog is configured to use the following Tailscale domain:

```
aerocoreos.tail79107c.ts.net
```

Music files are accessible via the path:

```
https://aerocoreos.tail79107c.ts.net/echoverse/Albums/
```

## How Tailscale Streaming Works

1. **Path Resolution**: When you click "Play" on a track, the system extracts the relative path from the full file path.
   
   Example:
   - Full path: `\\envy2-0\EchoVerse_Music\Albums\the pines\Cruisin' CDA (1).mp3`
   - Extracted: `the pines\Cruisin' CDA (1).mp3`

2. **Tailscale URL Creation**: The system creates a Tailscale URL using the extracted path.
   
   Example:
   - Tailscale URL: `https://aerocoreos.tail79107c.ts.net/echoverse/Albums/the pines/Cruisin' CDA (1).mp3`

3. **Secure Streaming**: The browser is redirected to the Tailscale URL, which provides encrypted streaming of the audio file.

4. **Automatic Fallback**: If Tailscale streaming fails for any reason, the system automatically falls back to direct streaming from the local server.

## API Endpoints

The catalog provides two endpoints for audio streaming:

1. **Regular Streaming API**:
   ```
   /api/audio/{file_path}?use_tailscale=[true|false]
   ```
   This endpoint supports both direct and Tailscale streaming based on the `use_tailscale` parameter.

2. **Direct Tailscale API**:
   ```
   /api/tailscale-audio/{relative_path}
   ```
   This endpoint always redirects to the Tailscale URL for the given relative path.

## Configuration Options

### Settings UI

The EchoVerse Music Catalog includes a settings page where you can configure Tailscale options:

1. Click on the **⚙️ Settings** link in the navigation bar
2. Update the following settings:
   - **Tailscale Full URL**: Your complete Tailscale URL including the path (e.g., `https://aerocoreos.tail79107c.ts.net/echoverse/Albums/`)
   - **Enable Tailscale Streaming**: Toggle Tailscale streaming on/off
   - **Enable Fallback**: Automatically fall back to direct streaming if Tailscale fails
3. Click **Save Configuration** to apply changes

### Configuration File

The Tailscale settings are stored in a JSON configuration file at `config/tailscale_config.json`:

```json
{
  "tailscale": {
    "domain": "https://aerocoreos.tail79107c.ts.net/echoverse/Albums/",
    "music_path": "",
    "enabled": true,
    "fallback_to_direct": true
  },
  "local_paths": {
    "network_share": "\\\\envy2-0\\EchoVerse_Music\\Albums\\",
    "local_drive": "M:\\Albums\\",
    "backup_drive": "D:\\Clients\\AeroVista\\Projects\\EchoVerse_Music\\Albums\\"
  }
}
```

Note: The `domain` field now contains the complete URL including the `https://` prefix and the full path.

You can edit this file directly if needed, but using the Settings UI is recommended.

## Troubleshooting

If you encounter issues with Tailscale streaming:

1. **Check Tailscale Status**: Ensure the Tailscale service is running on your server.
   
2. **Verify Network Access**: Make sure your client device has network access to the Tailscale domain.
   
3. **Check Console Logs**: Open the browser console (F12) to view detailed streaming logs.
   
4. **Try Direct Streaming**: The system will automatically fall back to direct streaming if Tailscale fails.

5. **Manual Override**: You can append `?use_tailscale=false` to any audio URL to force direct streaming.

## Security Considerations

- Tailscale provides end-to-end encryption for all audio streaming
- Access is limited to authenticated Tailscale network members
- No public internet exposure of your music files
- Automatic path validation prevents directory traversal attacks

## Performance Optimization

For optimal streaming performance:

1. **Local Network**: When on the same network as the server, direct streaming may be faster
   
2. **Remote Access**: Tailscale provides optimized routing for remote access
   
3. **Mobile Devices**: Tailscale works well on mobile networks and across NATs

## Additional Resources

- [Tailscale Documentation](https://tailscale.com/kb/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [HTML5 Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)

---

**Last Updated**: September 2025
