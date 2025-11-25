use crossterm::{
    event::{self, Event, KeyCode, KeyEvent},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph},
    Terminal,
};
use scraper::{Html, Selector};
use std::env;
use std::error::Error;
use std::io;
use std::process::Command;
use std::time::Duration;

fn truncate_string(s: &str, max_chars: usize) -> String {
    let char_count = s.chars().count();
    if char_count <= max_chars {
        s.to_string()
    } else {
        let truncated: String = s.chars().take(max_chars).collect();
        format!("{}...", truncated)
    }
}

// Sanitize string for display - remove problematic characters
fn sanitize_display(s: &str) -> String {
    s.chars()
        .filter(|c| !c.is_control() || *c == ' ')
        .collect::<String>()
        .trim()
        .to_string()
}

#[derive(Clone)]
struct SearchResult {
    title: String,
    url: String,
    display_url: String,
    description: String,
}

#[derive(PartialEq)]
enum Mode {
    Normal,
    Insert,
}

struct App {
    results: Vec<SearchResult>,
    list_state: ListState,
    mode: Mode,
    query: String,
    should_quit: bool,
}

impl App {
    fn new(results: Vec<SearchResult>, query: String) -> Self {
        let mut list_state = ListState::default();
        if !results.is_empty() {
            list_state.select(Some(0));
        }
        App {
            results,
            list_state,
            mode: Mode::Normal,
            query,
            should_quit: false,
        }
    }

    fn next(&mut self) {
        if self.results.is_empty() {
            return;
        }
        let i = match self.list_state.selected() {
            Some(i) => {
                if i >= self.results.len() - 1 {
                    0
                } else {
                    i + 1
                }
            }
            None => 0,
        };
        self.list_state.select(Some(i));
    }

    fn previous(&mut self) {
        if self.results.is_empty() {
            return;
        }
        let i = match self.list_state.selected() {
            Some(i) => {
                if i == 0 {
                    self.results.len() - 1
                } else {
                    i - 1
                }
            }
            None => 0,
        };
        self.list_state.select(Some(i));
    }

    fn open_selected(&self) {
        if let Some(i) = self.list_state.selected() {
            if let Some(result) = self.results.get(i) {
                if !result.url.is_empty() {
                    let _ = Command::new("open").arg(&result.url).spawn();
                }
            }
        }
    }
}

fn search(query: &str) -> Result<Vec<SearchResult>, Box<dyn Error>> {
    let encoded_query = query.replace(" ", "+");
    let url = format!("https://search.brave.com/search?q={}", encoded_query);

    let client = reqwest::blocking::Client::builder()
        .user_agent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        .timeout(Duration::from_secs(15))
        .build()?;

    let response = client
        .get(&url)
        .header("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
        .header("Accept-Language", "en-US,en;q=0.5")
        .send()?;
    let body = response.text()?;
    let document = Html::parse_document(&body);

    let mut results = Vec::new();

    let snippet_selector = Selector::parse("div.snippet").unwrap();
    let title_link_selector = Selector::parse("a.heading-serpresult, a[href]").unwrap();
    let title_selector = Selector::parse(".title").unwrap();
    let url_selector = Selector::parse(".snippet-url").unwrap();
    let desc_selector = Selector::parse(".snippet-description, .generic-snippet").unwrap();

    for snippet in document.select(&snippet_selector).take(10) {
        let title = snippet
            .select(&title_selector)
            .next()
            .map(|e| sanitize_display(&e.text().collect::<String>()))
            .unwrap_or_default();

        // Get the actual href from the title link
        let actual_url = snippet
            .select(&title_link_selector)
            .find(|e| {
                e.value()
                    .attr("href")
                    .map(|h| h.starts_with("http"))
                    .unwrap_or(false)
            })
            .and_then(|e| e.value().attr("href"))
            .unwrap_or_default()
            .to_string();

        // Get display URL for showing in UI
        let display_url = snippet
            .select(&url_selector)
            .next()
            .map(|e| {
                e.text()
                    .collect::<String>()
                    .replace("›", "/")
                    .split_whitespace()
                    .next()
                    .unwrap_or("")
                    .to_string()
            })
            .unwrap_or_default();

        let description = snippet
            .select(&desc_selector)
            .next()
            .map(|e| sanitize_display(&e.text().collect::<String>()))
            .unwrap_or_default();

        if !title.is_empty() && !actual_url.is_empty() {
            results.push(SearchResult {
                title: title.trim().to_string(),
                url: actual_url,
                display_url: display_url.trim().to_string(),
                description: description.trim().to_string(),
            });
        }
    }

    Ok(results)
}

fn run_app<B: ratatui::backend::Backend>(terminal: &mut Terminal<B>, mut app: App) -> io::Result<()> {
    loop {
        terminal.draw(|f| {
            let chunks = Layout::default()
                .direction(Direction::Vertical)
                .constraints([
                    Constraint::Length(3),
                    Constraint::Min(0),
                    Constraint::Length(3),
                ])
                .split(f.area());

            // Header
            let mode_str = match app.mode {
                Mode::Normal => "NORMAL",
                Mode::Insert => "INSERT",
            };
            let header = Paragraph::new(Line::from(vec![
                Span::styled(
                    format!(" {} ", mode_str),
                    Style::default()
                        .bg(if app.mode == Mode::Insert { Color::Green } else { Color::Blue })
                        .fg(Color::White)
                        .add_modifier(Modifier::BOLD),
                ),
                Span::raw("  Search: "),
                Span::styled(&app.query, Style::default().fg(Color::Yellow).add_modifier(Modifier::BOLD)),
            ]))
            .block(Block::default().borders(Borders::ALL).title("Ghost Browse"));
            f.render_widget(header, chunks[0]);

            // Results list
            let items: Vec<ListItem> = app
                .results
                .iter()
                .map(|r| {
                    let lines = vec![
                        Line::from(Span::styled(
                            truncate_string(&r.title, 70),
                            Style::default().fg(Color::Green).add_modifier(Modifier::BOLD),
                        )),
                        Line::from(Span::styled(
                            truncate_string(&r.display_url, 60),
                            Style::default().fg(Color::Cyan),
                        )),
                        Line::from(Span::styled(
                            truncate_string(&r.description, 80),
                            Style::default().fg(Color::White),
                        )),
                        Line::from(""),
                    ];
                    ListItem::new(lines)
                })
                .collect();

            let list = List::new(items)
                .block(Block::default().borders(Borders::ALL).title("Results"))
                .highlight_style(
                    Style::default()
                        .bg(Color::DarkGray)
                        .add_modifier(Modifier::BOLD),
                )
                .highlight_symbol(">> ");

            f.render_stateful_widget(list, chunks[1], &mut app.list_state);

            // Footer with keybindings
            let footer_text = match app.mode {
                Mode::Normal => " [i] Insert mode  [q] Quit ",
                Mode::Insert => " [j/k] Navigate  [Enter] Open  [Esc] Normal mode ",
            };
            let footer = Paragraph::new(footer_text)
                .style(Style::default().fg(Color::Gray))
                .block(Block::default().borders(Borders::ALL).title("Keys"));
            f.render_widget(footer, chunks[2]);
        })?;

        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(KeyEvent { code, .. }) = event::read()? {
                match app.mode {
                    Mode::Normal => match code {
                        KeyCode::Char('q') => {
                            app.should_quit = true;
                        }
                        KeyCode::Char('i') => {
                            app.mode = Mode::Insert;
                        }
                        _ => {}
                    },
                    Mode::Insert => match code {
                        KeyCode::Esc => {
                            app.mode = Mode::Normal;
                        }
                        KeyCode::Char('j') | KeyCode::Down => {
                            app.next();
                        }
                        KeyCode::Char('k') | KeyCode::Up => {
                            app.previous();
                        }
                        KeyCode::Char('h') | KeyCode::Left => {
                            app.previous();
                        }
                        KeyCode::Char('l') | KeyCode::Right => {
                            app.next();
                        }
                        KeyCode::Enter => {
                            app.open_selected();
                        }
                        _ => {}
                    },
                }
            }
        }

        if app.should_quit {
            return Ok(());
        }
    }
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: search <query>");
        eprintln!("Example: search rust programming");
        std::process::exit(1);
    }

    let query = args[1..].join(" ");

    // Show loading message
    println!("Searching for: {}...", query);

    let results = search(&query)?;

    if results.is_empty() {
        println!("No results found.");
        return Ok(());
    }

    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Run app
    let app = App::new(results, query);
    let res = run_app(&mut terminal, app);

    // Restore terminal
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;
    terminal.show_cursor()?;

    if let Err(err) = res {
        eprintln!("Error: {}", err);
    }

    Ok(())
}
