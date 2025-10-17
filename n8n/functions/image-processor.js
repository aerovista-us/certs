// N8N Function: Image Processor
// Input: items[0].json.filepath
// Purpose: Copy image files to outbox with date-based organization

const fp = $json.filepath;
const day = new Date().toISOString().slice(0,10);
const out = `/srv/exchange/outbox/${day}/images`;
const { execSync } = require('child_process');

try {
  // Create directory and copy file
  execSync(`mkdir -p "${out}" && cp "${fp}" "${out}/"`);
  
  return [{ 
    json: { 
      status: "copied", 
      outdir: out,
      originalFile: fp,
      timestamp: new Date().toISOString()
    } 
  }];
} catch (error) {
  return [{ 
    json: { 
      status: "error", 
      error: error.message,
      originalFile: fp
    } 
  }];
}
