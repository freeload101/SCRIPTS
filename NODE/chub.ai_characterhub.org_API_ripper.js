// My first puppeteer code 
// replace url = with what ever params you are looking for etc ...
// run the script again and it will convert {{user}} to {{char}} and name them *modded*

const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-accelerated-2d-canvas',
      '--disable-gpu'
    ],
    defaultViewport: { width: 1920, height: 1080 }
  });
  
  const page = await browser.newPage();
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3');
  
  const url = 'https://api.chub.ai/search?search=&topics=NSFW,Female,Human&excludetopics=Fempov,Demon,Horror&page=1&sort=star_count&venus=false&min_tokens=50&first=100&page=1&nsfw=true&nsfl=true';
  await page.goto(url);
  
  const htmlContent = await page.content();
  const jsonData = parseJsonFromHtml(htmlContent);
  
  const Chars = jsonData.data.nodes;
  for (let i = 0; i < Chars.length; i++) {
    console.log("Char ID:", Chars[i].fullPath);
    
    const page = await browser.newPage();
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3');
    
    const url = 'https://api.chub.ai/api/v4/projects/' + Chars[i].id + '/repository/files/raw%252Ftavern_raw.json/raw?ref=main&response_type=blob';
    await page.goto(url);
    
    const htmlContent = await page.content();
    let trimandtailHEAD = htmlContent.replace(/<html><head><meta name=\"color-scheme\" content=\"light dark\"><meta charset=\"utf-8\"><\/head><body><pre>/g, "")
    let trimandtailTAIL = trimandtailHEAD.replace(/<\/pre><div class=\"json-formatter-container\"><\/div><\/body><\/html>/g, "")
    
    const fs = require('fs');
    const var2 = Chars[i].fullPath + '.json';
    fs.writeFile(var2.replace(/\//g, "_"), trimandtailTAIL, () => {}); 
  }
  
  await browser.close();
})();

function parseJsonFromHtml(html) {
  const jsonMatch = html.match(/(\{.*\})/);
  return jsonMatch ? JSON.parse(jsonMatch[0]) : null;
}




const fs = require('fs');
const path = require('path');

function replaceInJson(jsonString) {
    return jsonString.replace(/\{\{user/g, '\{\{char');
}

const cwd = process.cwd();

fs.readdir(cwd, (err, files) => {
    if (err) throw err;
    const jsonFiles = files.filter(file => path.extname(file).toLowerCase() === '.json');
    jsonFiles.forEach(file => {
        const filePath = path.join(cwd, file);
        fs.readFile(filePath, 'utf8', (err, data) => {
            if (err) throw err;
            const modifiedData = replaceInJson(data);
            const outputFilePath = path.join(cwd, `${path.basename(file, '.json')}_modified${path.extname(file)}`);
            fs.writeFile(outputFilePath, modifiedData, 'utf8', (err) => {
                if (err) throw err;
                console.log(`Modified file saved as: ${outputFilePath}`);
            });
        });
    });
});
