use colored::*;
use scraper::{Html, Selector};
use std::env;
use std::error::Error;

fn search_duckduckgo(query: &str) -> Result<Vec<(String, String, String)>, Box<dyn Error>> {
    let url = format!("https://html.duckduckgo.com/html/?q={}",
                     query.replace(" ", "+"));

    let client = reqwest::blocking::Client::builder()
        .user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        .build()?;

    let response = client.get(&url).send()?;
    let body = response.text()?;
    let document = Html::parse_document(&body);

    let result_selector = Selector::parse(".result").unwrap();
    let title_selector = Selector::parse(".result__a").unwrap();
    let snippet_selector = Selector::parse(".result__snippet").unwrap();
    let url_selector = Selector::parse(".result__url").unwrap();

    let mut results = Vec::new();

    for result in document.select(&result_selector).take(10) {
        let title = result
            .select(&title_selector)
            .next()
            .map(|e| e.text().collect::<String>())
            .unwrap_or_default();

        let snippet = result
            .select(&snippet_selector)
            .next()
            .map(|e| e.text().collect::<String>())
            .unwrap_or_default();

        let url = result
            .select(&url_selector)
            .next()
            .map(|e| e.text().collect::<String>())
            .unwrap_or_default();

        if !title.is_empty() {
            results.push((title.trim().to_string(), url.trim().to_string(), snippet.trim().to_string()));
        }
    }

    Ok(results)
}

fn display_results(results: &[(String, String, String)]) {
    println!("\n{}\n", "Search Results:".bright_cyan().bold());

    for (i, (title, url, snippet)) in results.iter().enumerate() {
        println!("{}. {}",
                 format!("{}", i + 1).bright_yellow().bold(),
                 title.bright_green().bold());
        println!("   {}", url.bright_blue());
        println!("   {}\n", snippet.white());
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("{}", "Usage: search <query>".bright_red());
        eprintln!("{}", "Example: search rust programming".bright_yellow());
        std::process::exit(1);
    }

    let query = args[1..].join(" ");

    println!("{} {}", "Searching anonymously for:".bright_cyan(), query.bright_white().bold());

    match search_duckduckgo(&query) {
        Ok(results) => {
            if results.is_empty() {
                println!("{}", "No results found.".bright_yellow());
            } else {
                display_results(&results);
            }
        }
        Err(e) => {
            eprintln!("{} {}", "Error searching:".bright_red(), e);
            std::process::exit(1);
        }
    }
}
