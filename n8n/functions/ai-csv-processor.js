// N8N Function: AI-Enhanced CSV Processor
// Input: items[0].json.filepath
// Purpose: Process CSV files with AI analysis and copy to outbox

const fp = $json.filepath;
const day = new Date().toISOString().slice(0,10);
const out = `/srv/exchange/outbox/${day}/ai`;
const { execSync } = require('child_process');

try {
  // Create directory
  execSync(`mkdir -p "${out}"`);
  
  // Copy original file
  execSync(`cp "${fp}" "${out}/"`);
  
  // Run AI analysis
  const aiScript = '/srv/core/nxcore/ai/ai-processor.sh';
  const analysisResult = execSync(`${aiScript} process "${fp}" "${out}" llama3.2`, { 
    encoding: 'utf8',
    timeout: 30000 // 30 second timeout
  });
  
  return [{ 
    json: { 
      status: "ai_processed", 
      outdir: out,
      originalFile: fp,
      analysisResult: analysisResult.trim(),
      timestamp: new Date().toISOString()
    } 
  }];
} catch (error) {
  // Fallback to simple copy if AI processing fails
  try {
    execSync(`cp "${fp}" "${out}/"`);
    return [{ 
      json: { 
        status: "copied_fallback", 
        outdir: out,
        originalFile: fp,
        error: error.message,
        timestamp: new Date().toISOString()
      } 
    }];
  } catch (fallbackError) {
    return [{ 
      json: { 
        status: "error", 
        error: error.message,
        fallbackError: fallbackError.message,
        originalFile: fp
      } 
    }];
  }
}
