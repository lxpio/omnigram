#!/usr/bin/env node

/**
 * Format changelog for Telegram message with length constraints
 * 
 * Telegram message max length: 4096 characters
 * Strategy:
 * 1. Try full changelog
 * 2. If too long, filter only Feat entries + footer message
 * 3. If still too long, truncate to MAX_LENGTH characters
 */

const fs = require('fs');
const path = require('path');

// Telegram message length limit
const MAX_LENGTH = 3500;
// Reserve space for the header and download link (estimated ~200 chars)
const HEADER_FOOTER_RESERVE = 200;
const AVAILABLE_LENGTH = MAX_LENGTH - HEADER_FOOTER_RESERVE;

// Footer messages for truncated content
const FOOTER_EN = '\nFor more fixes and improvements, see the full changelog on GitHub._';
const FOOTER_ZH = '\n更多修复和改进见 GitHub 完整更新日志。_';
const TRUNCATE_SUFFIX_EN = '\n...and more. See full changelog on GitHub._';
const TRUNCATE_SUFFIX_ZH = '\n...等更多内容。完整更新日志见 GitHub。_';

/**
 * Extract changelog for a specific version
 */
function extractVersionChangelog(changelogContent, version) {
  const lines = changelogContent.split('\n');
  const versionHeader = `## ${version}`;
  
  let startIndex = -1;
  let endIndex = lines.length;
  
  // Find version start
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].trim() === versionHeader) {
      startIndex = i;
      break;
    }
  }
  
  if (startIndex === -1) {
    throw new Error(`Version ${version} not found in changelog`);
  }
  
  // Find next version (end of current version)
  for (let i = startIndex + 1; i < lines.length; i++) {
    if (lines[i].trim().startsWith('## ')) {
      endIndex = i;
      break;
    }
  }
  
  return lines.slice(startIndex + 1, endIndex).join('\n').trim();
}

/**
 * Split changelog into English and Chinese sections
 */
function splitChangelogSections(changelog) {
  const sections = changelog.split('\n\n');
  
  if (sections.length < 2) {
    return { english: changelog, chinese: '' };
  }
  
  // Find the split point (blank line between English and Chinese)
  let englishLines = [];
  let chineseLines = [];
  let foundSplit = false;
  
  const lines = changelog.split('\n');
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    // Detect Chinese section start (lines starting with - and containing Chinese characters)
    if (!foundSplit && line.match(/^-\s.*[\u4e00-\u9fa5]/)) {
      foundSplit = true;
    }
    
    if (foundSplit) {
      chineseLines.push(line);
    } else if (line.trim()) {
      englishLines.push(line);
    }
  }
  
  return {
    english: englishLines.join('\n').trim(),
    chinese: chineseLines.join('\n').trim()
  };
}

/**
 * Filter only Feat entries from changelog
 */
function filterFeatEntries(changelog) {
  const lines = changelog.split('\n');
  return lines
    .filter(line => {
      const trimmed = line.trim();
      return trimmed.startsWith('- Feat') || trimmed === '';
    })
    .join('\n')
    .trim();
}

/**
 * Format changelog with length constraints
 */
function formatChangelog(changelog) {
  // Try full changelog first
  if (changelog.length <= AVAILABLE_LENGTH) {
    return changelog;
  }
  
  console.error(`Changelog too long (${changelog.length} chars), filtering Feat entries only...`);
  
  // Split into English and Chinese sections
  const { english, chinese } = splitChangelogSections(changelog);
  
  // Filter only Feat entries
  const englishFeat = filterFeatEntries(english);
  const chineseFeat = filterFeatEntries(chinese);
  
  // Reconstruct with footer message
  let filtered = englishFeat;
  if (englishFeat) {
    filtered += FOOTER_EN;
  }
  if (chineseFeat) {
    filtered += '\n\n' + chineseFeat;
  }
  if (chineseFeat) {
    filtered += FOOTER_ZH;
  }
  
  // Check if filtered version fits
  if (filtered.length <= AVAILABLE_LENGTH) {
    return filtered;
  }
  
  console.error(`Still too long (${filtered.length} chars), truncating...`);
  
  // Truncate to fit within limit
  // Split into English and Chinese again for smart truncation
  const { english: engFeat, chinese: zhFeat } = splitChangelogSections(filtered);
  
  // Calculate how much space we have
  const suffixLength = TRUNCATE_SUFFIX_EN.length + TRUNCATE_SUFFIX_ZH.length + 4; // +4 for \n\n spacing
  const maxContentLength = AVAILABLE_LENGTH - suffixLength;
  
  // Allocate space proportionally, but prioritize keeping some of both sections
  const halfSpace = Math.floor(maxContentLength / 2);
  
  let truncatedEng = engFeat;
  let truncatedZh = zhFeat;
  
  if (engFeat.length > halfSpace) {
    truncatedEng = truncateToLastCompleteLine(engFeat, halfSpace - TRUNCATE_SUFFIX_EN.length);
  }
  
  if (zhFeat.length > halfSpace) {
    truncatedZh = truncateToLastCompleteLine(zhFeat, halfSpace - TRUNCATE_SUFFIX_ZH.length);
  }
  
  // Reconstruct truncated message
  let result = truncatedEng;
  if (truncatedEng.length < engFeat.length) {
    result += TRUNCATE_SUFFIX_EN;
  }
  if (truncatedZh) {
    result += '\n\n' + truncatedZh;
  }
  if (truncatedZh.length < zhFeat.length) {
    result += TRUNCATE_SUFFIX_ZH;
  }
  
  return result;
}

/**
 * Truncate to last complete line within maxLength
 */
function truncateToLastCompleteLine(text, maxLength) {
  if (text.length <= maxLength) {
    return text;
  }
  
  const truncated = text.substring(0, maxLength);
  const lastNewline = truncated.lastIndexOf('\n');
  
  if (lastNewline > 0) {
    return truncated.substring(0, lastNewline).trim();
  }
  
  return truncated.trim();
}

/**
 * Main function
 */
function main() {
  const args = process.argv.slice(2);
  
  if (args.length < 2) {
    console.error('Usage: format_telegram_message.js <changelog_path> <version>');
    process.exit(1);
  }
  
  const changelogPath = args[0];
  const version = args[1];
  
  try {
    // Read changelog
    const changelogContent = fs.readFileSync(changelogPath, 'utf8');
    
    // Extract version changelog
    const versionChangelog = extractVersionChangelog(changelogContent, version);
    
    // Format with length constraints
    const formatted = formatChangelog(versionChangelog);
    
    // Output result
    console.log(formatted);
    
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

// Run if executed directly
if (require.main === module) {
  main();
}

module.exports = { formatChangelog, extractVersionChangelog };
