const { chromium } = require('playwright');
const fs = require('fs').promises;
const path = require('path');
const readline = require('readline');
const { jsonToToon } = require('toon-json-converter');

// Create output directory name with timestamp
const OUTPUT_DIR = `output_${new Date().toISOString().replace(/[:.]/g, '-').split('T')[0]}`;

async function ensureOutputDir() {
  try {
    await fs.access(OUTPUT_DIR);
  } catch {
    await fs.mkdir(OUTPUT_DIR, { recursive: true });
    console.log(`📁 Created output directory: ${OUTPUT_DIR}\n`);
  }
}

function getChromeExecutablePath() {
  return '.\\Chromium\\chrome.exe';
}

function getChromeUserDataDir() {
  const homeDir = require('os').homedir();
  return path.join(homeDir, 'AppData', 'Local', 'Google', 'Chrome', 'User Data');
}

async function extractWebpageContent(page, url, sessionId, urlIndex, totalUrls) {
  console.log(`\n[Session ${sessionId}][${urlIndex}/${totalUrls}] 🚀 Processing: ${url}\n`);

  try {
    await page.goto(url, { 
      waitUntil: 'domcontentloaded',
      timeout: 90000 
    });
    console.log(`[Session ${sessionId}] ✓ Page loaded\n`);
  } catch (error) {
    console.log(`[Session ${sessionId}] ⚠️  Timeout/Error: ${error.message}`);
    console.log(`[Session ${sessionId}] ⏳ Retrying with networkidle...`);
    await page.goto(url, { 
      waitUntil: 'networkidle',
      timeout: 120000 
    });
  }

  await page.waitForTimeout(2000);
  await page.keyboard.press('End');
  await page.waitForTimeout(1000);

  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const sanitizedUrl = url.replace(/[^a-z0-9]/gi, '_').substring(0, 50);
  const screenshotPath = path.join(OUTPUT_DIR, `${sanitizedUrl}_${timestamp}_s${sessionId}.png`);
  await page.screenshot({ path: screenshotPath, fullPage: true });
  console.log(`[Session ${sessionId}] 📸 Screenshot saved: ${screenshotPath}\n`);

  const content = await page.evaluate(() => {
    ['script', 'style', 'noscript'].forEach(tag => {
      document.querySelectorAll(tag).forEach(el => el.remove());
    });

    const getElementMetadata = (el) => {
      const rect = el.getBoundingClientRect();
      const styles = window.getComputedStyle(el);
      return {
        visible: styles.display !== 'none' && styles.visibility !== 'hidden' && rect.width > 0 && rect.height > 0,
        position: {
          x: Math.round(rect.left),
          y: Math.round(rect.top),
          width: Math.round(rect.width),
          height: Math.round(rect.height)
        },
        styles: {
          display: styles.display,
          position: styles.position,
          zIndex: styles.zIndex
        }
      };
    };

    const metadata = {
      url: window.location.href,
      title: document.title,
      scraped_at: new Date().toISOString(),
      charset: document.characterSet,
      language: document.documentElement.lang || 'unknown',
      viewport: {
        width: window.innerWidth,
        height: window.innerHeight
      },
      meta_tags: Array.from(document.querySelectorAll('meta')).map(meta => ({
        name: meta.name || meta.getAttribute('property') || meta.getAttribute('http-equiv'),
        content: meta.content
      })).filter(m => m.name),
      canonical: document.querySelector('link[rel="canonical"]')?.href || null,
      favicon: document.querySelector('link[rel*="icon"]')?.href || null,
      word_count: document.body.innerText.split(/\s+/).filter(w => w).length
    };

    const structuredData = Array.from(document.querySelectorAll('script[type="application/ld+json"]'))
      .map(script => {
        try {
          return JSON.parse(script.textContent);
        } catch {
          return null;
        }
      })
      .filter(d => d);

    const navigation = Array.from(document.querySelectorAll('nav, [role="navigation"]')).map((nav, idx) => ({
      index: idx,
      aria_label: nav.getAttribute('aria-label') || null,
      links: Array.from(nav.querySelectorAll('a')).map(a => ({
        text: a.innerText.trim(),
        href: a.href,
        title: a.title || null
      }))
    }));

    const links = Array.from(document.querySelectorAll('a[href]')).map(a => {
      const meta = getElementMetadata(a);
      return {
        text: a.innerText.trim() || a.getAttribute('aria-label') || 'No text',
        href: a.href,
        title: a.title || null,
        target: a.target || null,
        rel: a.rel || null,
        context: a.closest('nav') ? 'navigation' : 
                 a.closest('header') ? 'header' :
                 a.closest('footer') ? 'footer' :
                 a.closest('aside') ? 'sidebar' : 'main',
        visible: meta.visible
      };
    });

    const buttons = Array.from(document.querySelectorAll('button, [role="button"], input[type="button"], input[type="submit"]')).map(btn => {
      const meta = getElementMetadata(btn);
      return {
        text: btn.innerText.trim() || btn.value || btn.getAttribute('aria-label') || 'No text',
        type: btn.getAttribute('type') || 'button',
        aria_label: btn.getAttribute('aria-label') || null,
        aria_expanded: btn.getAttribute('aria-expanded') || null,
        disabled: btn.disabled,
        form_id: btn.form?.id || null,
        visible: meta.visible,
        position: meta.position
      };
    });

    const forms = Array.from(document.querySelectorAll('form')).map((form, idx) => ({
      index: idx,
      id: form.id || null,
      name: form.name || null,
      action: form.action || null,
      method: form.method || 'get',
      enctype: form.enctype || null,
      fields: Array.from(form.querySelectorAll('input, textarea, select')).map(field => ({
        tag: field.tagName.toLowerCase(),
        type: field.type || 'text',
        name: field.name || null,
        id: field.id || null,
        placeholder: field.placeholder || null,
        required: field.required,
        value: field.value || null,
        label: field.labels?.[0]?.innerText.trim() || null,
        options: field.tagName === 'SELECT' ? 
          Array.from(field.options).map(opt => ({
            text: opt.text.trim(),
            value: opt.value
          })) : null
      }))
    }));

    const inputs = Array.from(document.querySelectorAll('input, textarea')).map(input => ({
      type: input.type || 'text',
      name: input.name || null,
      id: input.id || null,
      placeholder: input.placeholder || null,
      required: input.required,
      pattern: input.pattern || null,
      maxlength: input.maxLength > 0 ? input.maxLength : null,
      autocomplete: input.autocomplete || null,
      label: input.labels?.[0]?.innerText.trim() || null
    }));

    const selects = Array.from(document.querySelectorAll('select')).map(select => ({
      name: select.name || null,
      id: select.id || null,
      multiple: select.multiple,
      size: select.size,
      options: Array.from(select.options).map(opt => ({
        text: opt.text.trim(),
        value: opt.value,
        selected: opt.selected
      }))
    }));

    const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6')).map((h, idx) => ({
      index: idx,
      level: h.tagName.toLowerCase(),
      text: h.innerText.trim(),
      id: h.id || null
    }));

    const lists = Array.from(document.querySelectorAll('ul, ol')).map((list, idx) => ({
      index: idx,
      type: list.tagName.toLowerCase(),
      items: Array.from(list.children).filter(li => li.tagName === 'LI').map(li => li.innerText.trim())
    }));

    const tables = Array.from(document.querySelectorAll('table')).map((table, idx) => {
      const headers = Array.from(table.querySelectorAll('th')).map(th => th.innerText.trim());
      const rows = Array.from(table.querySelectorAll('tbody tr, tr')).map(tr => 
        Array.from(tr.querySelectorAll('td')).map(td => td.innerText.trim())
      ).filter(row => row.length > 0);

      return {
        index: idx,
        caption: table.querySelector('caption')?.innerText.trim() || null,
        headers,
        row_count: rows.length,
        col_count: headers.length || (rows[0]?.length || 0),
        rows: rows.slice(0, 100)
      };
    });

    const main = document.querySelector('main, [role="main"], article') || document.body;
    const paragraphs = Array.from(main.querySelectorAll('p')).map(p => p.innerText.trim()).filter(t => t);
    const blockquotes = Array.from(document.querySelectorAll('blockquote')).map(bq => bq.innerText.trim());
    const preformatted = Array.from(document.querySelectorAll('pre, code')).map(pre => pre.innerText.trim());

    const images = Array.from(document.querySelectorAll('img')).map(img => ({
      src: img.src,
      alt: img.alt || null,
      title: img.title || null,
      width: img.width || null,
      height: img.height || null,
      loading: img.loading || null,
      srcset: img.srcset || null
    }));

    const videos = Array.from(document.querySelectorAll('video, iframe[src*="youtube"], iframe[src*="vimeo"]')).map(v => ({
      type: v.tagName.toLowerCase(),
      src: v.src || v.querySelector('source')?.src || null,
      poster: v.poster || null,
      controls: v.controls || null,
      autoplay: v.autoplay || null
    }));

    const audio = Array.from(document.querySelectorAll('audio')).map(a => ({
      src: a.src || a.querySelector('source')?.src || null,
      controls: a.controls,
      autoplay: a.autoplay
    }));

    const iframes = Array.from(document.querySelectorAll('iframe')).map(iframe => ({
      src: iframe.src,
      title: iframe.title || null,
      width: iframe.width || null,
      height: iframe.height || null
    }));

    const dialogs = Array.from(document.querySelectorAll('dialog, [role="dialog"], [role="alertdialog"]')).map(d => ({
      open: d.open || d.style.display !== 'none',
      aria_label: d.getAttribute('aria-label') || null,
      content: d.innerText.trim().substring(0, 500)
    }));

    const accordions = Array.from(document.querySelectorAll('details, [aria-expanded]')).map(acc => ({
      type: acc.tagName.toLowerCase(),
      summary: acc.querySelector('summary')?.innerText.trim() || acc.innerText.split('\n')[0],
      expanded: acc.open || acc.getAttribute('aria-expanded') === 'true',
      content: acc.tagName === 'DETAILS' ? 
        Array.from(acc.children).filter(c => c.tagName !== 'SUMMARY').map(c => c.innerText.trim()).join('\n') :
        acc.innerText.trim()
    }));

    const breadcrumbs = Array.from(document.querySelectorAll('[aria-label*="breadcrumb"], .breadcrumb, nav ol')).map(bc => ({
      items: Array.from(bc.querySelectorAll('a, li')).map(item => ({
        text: item.innerText.trim(),
        href: item.href || null
      }))
    }));

    return {
      metadata,
      structured_data: structuredData,
      navigation,
      interactive_elements: {
        links,
        buttons,
        forms,
        inputs,
        selects,
        dialogs,
        accordions
      },
      content_structure: {
        headings,
        lists,
        tables,
        paragraphs,
        blockquotes,
        preformatted,
        breadcrumbs
      },
      media: {
        images,
        videos,
        audio,
        iframes
      },
      extraction_summary: {
        links_count: links.length,
        buttons_count: buttons.length,
        forms_count: forms.length,
        inputs_count: inputs.length,
        selects_count: selects.length,
        headings_count: headings.length,
        lists_count: lists.length,
        tables_count: tables.length,
        paragraphs_count: paragraphs.length,
        images_count: images.length,
        videos_count: videos.length,
        dialogs_count: dialogs.length,
        accordions_count: accordions.length
      }
    };
  });

  console.log(`[Session ${sessionId}] 📋 Extraction Summary:`);
  Object.entries(content.extraction_summary).forEach(([key, value]) => {
    console.log(`   ${key}: ${value}`);
  });
  console.log();

  return content;
}

function waitForEnterWithTimeout(message, timeoutMs) {
  return new Promise((resolve) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    let resolved = false;
    const timeout = setTimeout(() => {
      if (!resolved) {
        resolved = true;
        rl.close();
        resolve(false);
      }
    }, timeoutMs);

    rl.question(message, () => {
      if (!resolved) {
        resolved = true;
        clearTimeout(timeout);
        rl.close();
        resolve(true);
      }
    });
  });
}

class URLQueue {
  constructor(urls) {
    this.urls = urls;
    this.processedUrls = new Set();
    this.currentIndex = 0;
  }

  getNext() {
    while (this.currentIndex < this.urls.length) {
      const url = this.urls[this.currentIndex];
      this.currentIndex++;

      if (!this.processedUrls.has(url)) {
        this.processedUrls.add(url);
        return { url, index: this.currentIndex };
      }
    }
    return null;
  }

  hasMore() {
    return this.currentIndex < this.urls.length;
  }

  getProgress() {
    return {
      processed: this.processedUrls.size,
      total: this.urls.length,
      remaining: this.urls.length - this.processedUrls.size
    };
  }
}

async function processSession(browser, urlQueue, sessionId, results) {
  const context = await browser.newContext({
    viewport: { width: 1080, height: 1024 }
  });
  const page = await context.newPage();

  console.log(`\n[Session ${sessionId}] 🆕 New session created\n`);

  while (true) {
    const next = urlQueue.getNext();
    if (!next) break;

    const { url, index } = next;
    const progress = urlQueue.getProgress();

    try {
      const content = await extractWebpageContent(page, url, sessionId, index, progress.total);

      const jsonOutput = JSON.stringify(content, null, 2);
      const timestamp = new Date().toISOString().split('T')[0];
      const sanitizedUrl = url.replace(/[^a-z0-9]/gi, '_').substring(0, 50);
      const filename = path.join(OUTPUT_DIR, `${sanitizedUrl}_${timestamp}_s${sessionId}.json`);

      await fs.writeFile(filename, jsonOutput);

      console.log(`[Session ${sessionId}] ✅ Saved: ${filename}`);
      console.log(`[Session ${sessionId}] 📊 Tokens: ~${Math.floor(jsonOutput.length / 4)}`);
      console.log(`[Session ${sessionId}] 📈 Progress: ${progress.processed}/${progress.total}\n`);

      results.push({ url, filename, status: 'success', sessionId });

    } catch (error) {
      console.error(`[Session ${sessionId}] ❌ Error processing ${url}: ${error.message}\n`);
      results.push({ url, filename: null, status: 'error', error: error.message, sessionId });
    }
  }

  await context.close();
  console.log(`\n[Session ${sessionId}] ✓ Session completed\n`);
}

async function convertAllJsonToToon() {
  console.log('\n' + '='.repeat(60));
  console.log('🔄 Converting JSON files to TOON format...');
  console.log('='.repeat(60) + '\n');

  const files = await fs.readdir(OUTPUT_DIR);
  const jsonFiles = files.filter(file => path.extname(file) === '.json');

  if (jsonFiles.length === 0) {
    console.log('⚠️  No JSON files found to convert\n');
    return;
  }

  let successCount = 0;
  let errorCount = 0;

  for (const file of jsonFiles) {
    try {
      const filePath = path.join(OUTPUT_DIR, file);
      const content = await fs.readFile(filePath, 'utf-8');
      const jsonData = JSON.parse(content);

      const toonData = jsonToToon(jsonData);
      const outputFile = path.join(OUTPUT_DIR, file.replace('.json', '.toon'));
      await fs.writeFile(outputFile, toonData, 'utf-8');

      const jsonSize = content.length;
      const toonSize = toonData.length;
      const savings = ((1 - toonSize / jsonSize) * 100).toFixed(1);

      console.log(`✓ ${file} → ${path.basename(outputFile)}`);
      console.log(`  Size: ${jsonSize} → ${toonSize} bytes (${savings}% reduction)`);
      console.log(`  Tokens: ~${Math.floor(jsonSize / 4)} → ~${Math.floor(toonSize / 4)}\n`);

      successCount++;
    } catch (error) {
      console.error(`✗ Failed to convert ${file}: ${error.message}\n`);
      errorCount++;
    }
  }

  console.log('='.repeat(60));
  console.log(`✅ Conversion complete: ${successCount} successful, ${errorCount} failed`);
  console.log('='.repeat(60) + '\n');
}

async function processUrlsFromFile(inputFile) {
  console.log(`\n📂 Reading URLs from: ${inputFile}\n`);

  const fileContent = await fs.readFile(inputFile, 'utf-8');
  const urls = fileContent.split('\n').map(line => line.trim()).filter(line => line && !line.startsWith('#'));

  console.log(`✓ Found ${urls.length} URLs to process\n`);

  await ensureOutputDir();

  const executablePath = getChromeExecutablePath();
  console.log(`🔧 Chrome executable: ${executablePath}\n`);

  const browser = await chromium.launch({
    headless: false,
    executablePath: executablePath,
    args: [
      '--disable-blink-features=AutomationControlled',
      '--enable-extensions'
    ]
  });

  const context = await browser.newContext({
    viewport: { width: 1080, height: 1024 }
  });
  const page = await context.newPage();

 
  console.log('⏳ Waiting for BOT challenge (max 60 seconds)...');
  console.log('   Press ENTER to continue immediately after passing challenge\n');
  await waitForEnterWithTimeout('', 60000);
  console.log('✓ Proceeding with URL processing...\n');
  const urlQueue = new URLQueue(urls);
  const results = [];
  const activeSessions = [];
  let sessionCounter = 1;

  const mainSessionPromise = processSession(browser, urlQueue, sessionCounter, results);
  activeSessions.push(mainSessionPromise);

  const checkInterval = setInterval(async () => {
    if (urlQueue.hasMore()) {
      console.log(`\n${'='.repeat(60)}`);
      console.log(`⏸️  Press ENTER within 2 seconds to add a new parallel session...`);
      console.log(`   Remaining URLs: ${urlQueue.getProgress().remaining}`);
      console.log('='.repeat(60));

      const userPressedEnter = await waitForEnterWithTimeout('', 2000);

      if (userPressedEnter) {
        sessionCounter++;
        const newSessionPromise = processSession(browser, urlQueue, sessionCounter, results);
        activeSessions.push(newSessionPromise);
        console.log(`\n[Session ${sessionCounter}] 🚀 Parallel session started\n`);
      }
    } else {
      clearInterval(checkInterval);
    }
  }, 5000);

  await Promise.all(activeSessions);
  clearInterval(checkInterval);

  await browser.close();

  console.log('\n' + '='.repeat(60));
  console.log('📊 BATCH PROCESSING COMPLETE');
  console.log('='.repeat(60));
  console.log(`Total URLs: ${urls.length}`);
  console.log(`Successful: ${results.filter(r => r.status === 'success').length}`);
  console.log(`Errors: ${results.filter(r => r.status === 'error').length}`);
  console.log(`Sessions used: ${sessionCounter}`);
  console.log(`Output directory: ${OUTPUT_DIR}`);
  console.log('='.repeat(60) + '\n');

  await convertAllJsonToToon();

  return results;
}

const inputFile = process.argv[2] || 'urls.txt';
processUrlsFromFile(inputFile).catch(err => {
  console.error('❌ Fatal Error:', err.message);
  process.exit(1);
});
