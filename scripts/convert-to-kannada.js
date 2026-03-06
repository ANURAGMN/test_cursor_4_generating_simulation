/**
 * Converts simulation HTML files to Kannada student-specific versions.
 * Usage: node convert-to-kannada.js <path-to-html> <output-path>
 * Or: node convert-to-kannada.js --batch (processes from BRANCH_MAP)
 *
 * Applies: lang=kn, Kannada font, and a shared translation dictionary for common terms.
 */

const fs = require('fs');
const path = require('path');

const KANNADA_FONT_LINK = `<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Kannada:wght@400;500;600;700&display=swap" rel="stylesheet">`;

const COMMON_TRANSLATIONS = {
  // UI
  'Submit': 'ಸಲ್ಲಿಸಿ',
  'Adjust': 'ಸರಿಹೊಂದಿಸಿ',
  'Distance': 'ದೂರ',
  'Size': 'ಗಾತ್ರ',
  'Material': 'ಪದಾರ್ಥ',
  'Opaque': 'ಅಪಾರದರ್ಶಕ',
  'Translucent': 'ಅರೆಪಾರದರ್ಶಕ',
  'Transparent': 'ಪಾರದರ್ಶಕ',
  'Select': 'ಆಯ್ಕೆಮಾಡಿ',
  'Test': 'ಪರೀಕ್ಷೆ',
  'Result': 'ಫಲಿತಾಂಶ',
  'Conclusion': 'ತೀರ್ಮಾನ',
  'Solution:': 'ದ್ರಾವಣ:',
  'Solution': 'ದ್ರಾವಣ',
  'Original': 'ಮೂಲ',
  'No change': 'ಬದಲಾವಣೆ ಇಲ್ಲ',
  'Blue Litmus': 'ನೀಲಿ ಲಿಟ್ಮಸ್',
  'Red Litmus': 'ಕೆಂಪು ಲಿಟ್ಮಸ್',
  'Select a solution to test:': 'ಪರೀಕ್ಷಿಸಲು ದ್ರಾವಣ ಆಯ್ಕೆಮಾಡಿ:',
  'Dip Papers': 'ಕಾಗದಗಳನ್ನು ಮುಳುಗಿಸಿ',
  'What you discovered:': 'ನೀವು ಕಂಡುಕೊಂಡದ್ದು:',
  'Key Insight:': 'ಮುಖ್ಯ ಅಂತರ್ದೃಷ್ಟಿ:',
  'Acidic': 'ಆಮ್ಲೀಯ',
  'Basic': 'ಕ್ಷಾರೀಯ',
  'Neutral': 'ತಟಸ್ಥ',
  'ACIDIC': 'ಆಮ್ಲೀಯ',
  'BASIC': 'ಕ್ಷಾರೀಯ',
  'NEUTRAL': 'ತಟಸ್ಥ',
  'Blue': 'ನೀಲಿ',
  'Red': 'ಕೆಂಪು',
  'Lemon Juice': 'ನಿಂಬೆ ರಸ',
  'Vinegar': 'ವಿನಿಗರ್',
  'Curd/Yogurt': 'ಮೊಸರು',
  'Soap Solution': 'ಸಾಬೂನು ದ್ರಾವಣ',
  'Baking Soda': 'ಬೇಕಿಂಗ್ ಸೋಡಾ',
  'Lime Water': 'ಸುಣ್ಣದ ನೀರು',
  'Tap Water': 'ನಳ ನೀರು',
  'Sugar Solution': 'ಸಕ್ಕರೆ ದ್ರಾವಣ',
  'Salt Solution': 'ಉಪ್ಪು ದ್ರಾವಣ',
  'Lemon': 'ನಿಂಬೆ',
  'Vinegar': 'ವಿನಿಗರ್',
  'Curd': 'ಮೊಸರು',
  'Soap': 'ಸಾಬೂನು',
  'Baking Soda': 'ಬೇಕಿಂಗ್ ಸೋಡಾ',
  'Lime Water': 'ಸುಣ್ಣದ ನೀರು',
  'Tap Water': 'ನಳ ನೀರು',
  'Sugar': 'ಸಕ್ಕರೆ',
  'Salt': 'ಉಪ್ಪು',
  'Reference (baseline)': 'ಉಲ್ಲೇಖ (ಆಧಾರ)',
  'Experiment (change & observe)': 'ಪ್ರಯೋಗ (ಬದಲಾಯಿಸಿ ಮತ್ತು ಗಮನಿಸಿ)',
  'Light & Shadows': 'ಬೆಳಕು ಮತ್ತು ನೆರಳು',
  'Compare & Explore': 'ಹೋಲಿಕೆ ಮತ್ತು ಅನ್ವೇಷಣೆ',
};

function convertToKannada(htmlContent) {
  let out = htmlContent;

  // Set language
  out = out.replace(/<html lang="en">/i, '<html lang="kn" dir="ltr">');

  // Add Kannada font after <head> or after first <meta>
  if (!out.includes('Noto Sans Kannada')) {
    out = out.replace(/(<head[^>]*>)/i, '$1\n' + KANNADA_FONT_LINK);
    out = out.replace(
      /(body\s*\{[^}]*font-family:\s*)([^;]+);/,
      (_, prefix, font) => prefix + "'Noto Sans Kannada', " + font + ';'
    );
  }

  // Apply translations (longest first to avoid partial matches)
  const sorted = Object.entries(COMMON_TRANSLATIONS).sort((a, b) => b[0].length - a[0].length);
  for (const [en, kn] of sorted) {
    const re = new RegExp(en.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
    out = out.replace(re, kn);
  }

  return out;
}

function main() {
  const args = process.argv.slice(2);
  if (args.length < 2 && args[0] !== '--batch') {
    console.log('Usage: node convert-to-kannada.js <input.html> <output.html>');
    console.log('   or: node convert-to-kannada.js --batch');
    process.exit(1);
  }

  if (args[0] === '--batch') {
    const repoRoot = path.resolve(__dirname, '..');
    const outDir = path.join(repoRoot, 'kannada_simulations');
    const mappingPath = path.join(outDir, 'BRANCH_HTML_MAPPING.md');
    console.log('Batch mode: ensure you have checked out the desired branch, then run this script with explicit input/output for each file. See BRANCH_HTML_MAPPING.md.');
    process.exit(0);
  }

  const inputPath = path.resolve(args[0]);
  const outputPath = path.resolve(args[1]);

  if (!fs.existsSync(inputPath)) {
    console.error('Input file not found:', inputPath);
    process.exit(1);
  }

  const html = fs.readFileSync(inputPath, 'utf8');
  const converted = convertToKannada(html);
  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.writeFileSync(outputPath, converted, 'utf8');
  console.log('Written:', outputPath);
}

main();
