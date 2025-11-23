# Search - Anonymous Terminal Search Tool

**Search the web anonymously directly from your terminal.** No accounts, no tracking, no browser needed.

This command-line tool lets you perform web searches from anywhere in your terminal while maintaining your privacy through DuckDuckGo's anonymous search interface.

## Why?

The point of this project is simple: **search in your terminal anonymously**. No need to open a browser, no cookies tracking you, no search history stored. Just pure, fast, private search results delivered straight to your command line.

## Installation

### Quick Install

```bash
cargo install --path .
```

### Manual Install

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/search.git
cd search
```

2. Build and install:
```bash
cargo build --release
cp target/release/search ~/.cargo/bin/
```

3. Make sure `~/.cargo/bin` is in your PATH

## Usage

Simply type `search` followed by your query:

```bash
search rust programming
search how to cook pasta
search best laptop 2024
```

## Features

- **Anonymous**: All searches go through DuckDuckGo's HTML interface
- **No Account Required**: Start searching immediately
- **Fast**: Built in Rust for speed
- **Privacy-Focused**: No tracking, no logging, no cookies
- **Use Anywhere**: Works from any directory in your terminal

## Examples

```bash
# Search for programming topics
search python tutorial

# Search for general information
search weather forecast

# Search for news
search latest tech news

# Multi-word queries
search machine learning algorithms
```

## How It Works

- Uses DuckDuckGo's HTML search interface (no JavaScript tracking)
- Sends requests with a generic user agent for anonymity
- Parses and displays the top 10 results
- No data is stored locally

## Uninstall

To remove the search command:

```bash
rm ~/.cargo/bin/search
```

## Privacy

- No search history saved
- No cookies or session data
- No user tracking
- Anonymous requests to DuckDuckGo

## Technical Details

- Built with Rust
- Uses `reqwest` for HTTP requests
- Uses `scraper` for HTML parsing
- Colorized terminal output with `colored`
