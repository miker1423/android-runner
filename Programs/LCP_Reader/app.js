// Puppeteer is a headless browser
import puppeteer from 'puppeteer';
import fs from 'fs'
import { exit } from 'process';
const fsProm = fs.promises

const path = "../WebAppGenerator/websites.txt"
const websites = (await fsProm.readFile(path)).toString().split('\n');

// Tool to get the LCP of a website
const baseUrl = "https://pagespeed.web.dev/report?form_factor=mobile&url=";

async function checkWebsite(testUrl) {    
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    // Encode URL to test.
    const encodedUrl = encodeURIComponent(testUrl);
    // Append to base path.
    const url = baseUrl + encodedUrl;
    // Navigate to tool website
    const rendered = await page.goto(url);
    if(rendered.status() != 200){
        console.log("Failed to retrieve.");
    }
    // Selector to LCP in tool website.
    const selector = ".Ykn2A";
    // Wait for website to load.
    await page.waitForSelector(selector);
    // Get possible results.
    const results = await page.evaluate(selector => {
        return [...document.querySelectorAll(selector)]
                .map(span => span.textContent);
    }, selector);
    
    browser.close();
    // The first on the list is the LCP.
    return results[0];
}

let LCP = [];

// Iterate over all websites.
for(const website of websites){
    console.log('Getting for %s', website);
    try{
        const lcp = await checkWebsite(website);
        const index = lcp.indexOf(' ');
        // Remove unit and append to line.
        const line = website + "," + lcp.substring(0, index) + "\n";
        // Store result in array.
        LCP.push(line);
        console.log("success! %s, %f", website, lcp);
    } catch {
        console.log("skipping %s", website);
    }
    console.log("next...");
}

// Store results.
await fsProm.writeFile("./results.csv", "website,lcp\n");
for(const idx in LCP){
    await fsProm.appendFile("./results.csv", LCP[idx]);
}

exit(0);