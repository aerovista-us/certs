import { Parser, Call, CallAnalysis, CallMetadata, TranscriptEntry, CallType } from '../types'

/**
 * ICETAP Basic Parser
 * 
 * Handles the proprietary ICETAP Basic format from AWS Connect exports.
 * This format contains tab-delimited metadata followed by transcript entries.
 * Each call is separated by a Contact ID (UUID format).
 */
export class ICETAPBasicParser implements Parser {
  name = 'ICETAP Basic Parser'
  description = 'Proprietary parser for ICETAP Basic format with Contact ID segmentation'
  version = '1.0.0'
  
  // Contact ID regex pattern (UUID format)
  private CONTACT_ID_REGEX = /^[a-f0-9\-]{36}$/i
  
  // Positive and negative trigger words for sentiment analysis
  private positiveTriggers = [
    'excellent', 'great', 'good', 'satisfied', 'happy', 'pleased', 'thank you', 'thanks',
    'appreciate', 'helpful', 'resolved', 'fixed', 'solved', 'perfect', 'awesome', 'fantastic'
  ]
  
  private negativeTriggers = [
    'frustrated', 'angry', 'upset', 'disappointed', 'unhappy', 'terrible', 'awful', 'horrible',
    'problem', 'issue', 'complaint', 'dissatisfied', 'annoyed', 'irritated', 'mad'
  ]

  canParse(data: any): boolean {
    if (typeof data !== 'string') return false
    
    const lines = data.split(/\r?\n/).map(l => l.trim())
    
    // Check if we have at least one Contact ID
    let contactIdCount = 0
    for (let i = 0; i < Math.min(lines.length, 100); i++) {
      if (this.CONTACT_ID_REGEX.test(lines[i])) {
        contactIdCount++
        if (contactIdCount >= 2) break // We need at least 2 to confirm it's multi-call format
      }
    }
    
    return contactIdCount >= 1
  }

  validate(data: string): { isValid: boolean; errors: string[] } {
    const errors: string[] = []
    const lines = data.split(/\r?\n/).map(l => l.trim())
    
    let contactIdCount = 0
    for (let i = 0; i < lines.length; i++) {
      if (this.CONTACT_ID_REGEX.test(lines[i])) {
        contactIdCount++
      }
    }
    
    if (contactIdCount === 0) {
      errors.push('No valid Contact IDs found in data')
    }
    
    return {
      isValid: errors.length === 0,
      errors
    }
  }

  parse(data: string): Call[] {
    const lines = data.split(/\r?\n/).map(l => l.trim())
    const calls: Call[] = []
    let i = 0
    
    while (i < lines.length) {
      // Look for Contact ID (our primary landmark for call segmentation)
      if (this.CONTACT_ID_REGEX.test(lines[i])) {
        const contactId = lines[i]
        i++ // Move past the contact ID
        
        // Skip empty lines
        while (i < lines.length && !lines[i]) i++
        
        // Parse metadata section (short format)
        const metadata = this.parseMetadata(lines, i)
        i = metadata.nextIndex
        
        // Skip empty lines
        while (i < lines.length && !lines[i]) i++
        
        // Parse transcript section
        const transcript = this.parseTranscript(lines, i)
        i = transcript.nextIndex
        
        // Create call object
        const call: Call = {
          id: contactId,
          metadata: metadata.data,
          transcript: transcript.data,
          analysis: this.generateAnalysis(transcript.data),
          timestamp: new Date().toISOString(),
          source: 'ICETAP Basic Parser'
        }
        
        calls.push(call)
      } else {
        i++ // Skip lines that don't match our pattern
      }
    }
    
    return calls
  }

  private parseMetadata(lines: string[], startIndex: number): { data: CallMetadata; nextIndex: number } {
    const metadata: CallMetadata = {
      contactId: '',
      callId: '',
      duration: '',
      startTime: '',
      endTime: '',
      agentId: '',
      agentName: '',
      customerId: '',
      customerName: '',
      phoneNumber: '',
      callType: 'Inbound',
      disposition: '',
      queue: '',
      issue: '',
      outcome: '',
      summary: '',
      categories: []
    }
    
    let i = startIndex
    
    // Parse short metadata format (tab-delimited)
    if (i < lines.length && lines[i].includes('\t')) {
      const parts = lines[i].split('\t')
      if (parts.length >= 15) {
        metadata.contactId = parts[0] || ''
        metadata.callId = parts[1] || ''
        metadata.duration = parts[2] || ''
        metadata.startTime = parts[3] || ''
        metadata.endTime = parts[4] || ''
        metadata.agentId = parts[5] || ''
        metadata.agentName = parts[6] || ''
        metadata.customerId = parts[7] || ''
        metadata.customerName = parts[8] || ''
        metadata.phoneNumber = parts[9] || ''
        metadata.callType = parts[10] === 'Voice' ? 'Inbound' : 'Inbound'
        metadata.disposition = parts[11] || ''
        metadata.queue = parts[12] || ''
        metadata.issue = parts[13] || ''
        metadata.outcome = parts[14] || ''
      }
      i++
    }
    
    // Parse long metadata format (key-value pairs)
    while (i < lines.length && !this.CONTACT_ID_REGEX.test(lines[i])) {
      const line = lines[i]
      
      if (line.includes(':')) {
        const [key, value] = line.split(':', 2)
        const trimmedKey = key.trim()
        const trimmedValue = value.trim()
        
        switch (trimmedKey.toLowerCase()) {
          case 'contact id':
            metadata.contactId = trimmedValue
            break
          case 'call id':
            metadata.callId = trimmedValue
            break
          case 'duration':
            metadata.duration = trimmedValue
            break
          case 'start time':
            metadata.startTime = trimmedValue
            break
          case 'end time':
            metadata.endTime = trimmedValue
            break
          case 'agent id':
            metadata.agentId = trimmedValue
            break
          case 'agent name':
            metadata.agentName = trimmedValue
            break
          case 'customer id':
            metadata.customerId = trimmedValue
            break
          case 'customer name':
            metadata.customerName = trimmedValue
            break
          case 'phone number':
            metadata.phoneNumber = trimmedValue
            break
          case 'call type':
            metadata.callType = trimmedValue === 'Voice' ? 'Inbound' : 'Inbound'
            break
          case 'disposition':
            metadata.disposition = trimmedValue
            break
          case 'queue':
            metadata.queue = trimmedValue
            break
          case 'issue':
            metadata.issue = trimmedValue
            break
          case 'outcome':
            metadata.outcome = trimmedValue
            break
          case 'summary':
            metadata.summary = trimmedValue
            break
        }
      }
      
      i++
    }
    
    return { data: metadata, nextIndex: i }
  }

  private parseTranscript(lines: string[], startIndex: number): { data: TranscriptEntry[]; nextIndex: number } {
    const transcript: TranscriptEntry[] = []
    let i = startIndex
    
    // Continue parsing until we hit the next Contact ID or end of file
    while (i < lines.length && !this.CONTACT_ID_REGEX.test(lines[i])) {
      const line = lines[i]
      
      // Skip empty lines
      if (!line) {
        i++
        continue
      }
      
      // Look for transcript entries (format: [Speaker] [Timestamp] Text)
      const transcriptMatch = line.match(/^\[([^\]]+)\]\s*\[([^\]]+)\]\s*(.+)$/)
      if (transcriptMatch) {
        const [, speaker, timestamp, text] = transcriptMatch
        transcript.push({
          speaker: speaker.trim(),
          timestamp: timestamp.trim(),
          text: text.trim(),
          confidence: 1.0
        })
      } else if (line.includes('[') && line.includes(']')) {
        // Alternative format: Speaker [Timestamp] Text
        const altMatch = line.match(/^([^[]+)\s*\[([^\]]+)\]\s*(.+)$/)
        if (altMatch) {
          const [, speaker, timestamp, text] = altMatch
          transcript.push({
            speaker: speaker.trim(),
            timestamp: timestamp.trim(),
            text: text.trim(),
            confidence: 1.0
          })
        }
      }
      
      i++
    }
    
    return { data: transcript, nextIndex: i }
  }

  private generateAnalysis(transcript: TranscriptEntry[]): CallAnalysis {
    const allText = transcript.map(entry => entry.text).join(' ').toLowerCase()
    
    // Count positive and negative triggers
    let positiveCount = 0
    let negativeCount = 0
    
    this.positiveTriggers.forEach(trigger => {
      const regex = new RegExp(trigger, 'gi')
      const matches = allText.match(regex)
      if (matches) positiveCount += matches.length
    })
    
    this.negativeTriggers.forEach(trigger => {
      const regex = new RegExp(trigger, 'gi')
      const matches = allText.match(regex)
      if (matches) negativeCount += matches.length
    })
    
    // Calculate sentiment score
    const totalTriggers = positiveCount + negativeCount
    const sentiment = totalTriggers > 0 ? (positiveCount - negativeCount) / totalTriggers : 0
    
    // Extract keywords
    const words = allText.split(/\s+/).filter(word => word.length > 3)
    const wordCount: { [key: string]: number } = {}
    words.forEach(word => {
      wordCount[word] = (wordCount[word] || 0) + 1
    })
    
    const keywords = Object.entries(wordCount)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 10)
      .map(([word]) => word)
    
    // Determine quality score
    const quality = Math.max(0, Math.min(1, (sentiment + 1) / 2))
    
    return {
      sentiment,
      quality,
      keywords,
      topics: keywords.slice(0, 5),
      flags: {
        positive: positiveCount > 0,
        negative: negativeCount > 0,
        escalation: allText.includes('escalate') || allText.includes('supervisor'),
        resolution: allText.includes('resolved') || allText.includes('fixed') || allText.includes('solved')
      },
      insights: {
        callLength: transcript.length,
        agentTurns: transcript.filter(entry => entry.speaker.toLowerCase().includes('agent')).length,
        customerTurns: transcript.filter(entry => entry.speaker.toLowerCase().includes('customer')).length
      }
    }
  }

  getSampleData(): string {
    return `550e8400-e29b-41d4-a716-446655440000
Contact ID	Call ID	Duration	Start Time	End Time	Agent ID	Agent Name	Customer ID	Customer Name	Phone Number	Call Type	Disposition	Queue	Issue	Outcome
550e8400-e29b-41d4-a716-446655440000	CALL001	00:05:30	2024-01-15 10:30:00	2024-01-15 10:35:30	AGENT001	John Smith	CUST001	Jane Doe	+1234567890	Voice	Resolved	Support	Technical Issue	Resolved

[Agent] [10:30:05] Hello, thank you for calling support. How can I help you today?
[Customer] [10:30:10] Hi, I'm having trouble with my account login.
[Agent] [10:30:15] I understand. Let me help you with that. Can you provide your account number?

6ba7b810-9dad-11d1-80b4-00c04fd430c8
Contact ID	Call ID	Duration	Start Time	End Time	Agent ID	Agent Name	Customer ID	Customer Name	Phone Number	Call Type	Disposition	Queue	Issue	Outcome
6ba7b810-9dad-11d1-80b4-00c04fd430c8	CALL002	00:03:45	2024-01-15 11:00:00	2024-01-15 11:03:45	AGENT002	Sarah Johnson	CUST002	Mike Wilson	+1987654321	Voice	Resolved	Sales	Product Inquiry	Resolved

[Agent] [11:00:05] Good morning! Thank you for calling our sales department.
[Customer] [11:00:10] Hi, I'm interested in your premium package.
[Agent] [11:00:15] Excellent! I'd be happy to tell you about our premium features.`
  }

  getConfigurationSchema(): any {
    return {
      type: 'object',
      properties: {
        enableDuplicateDetection: {
          type: 'boolean',
          default: true,
          description: 'Enable duplicate call detection based on Contact ID'
        },
        sentimentAnalysis: {
          type: 'boolean',
          default: true,
          description: 'Enable sentiment analysis using trigger words'
        }
      }
    }
  }
}
