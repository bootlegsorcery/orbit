use serde::Deserialize;
use std::path::PathBuf;

#[derive(Debug, Clone, Deserialize)]
pub struct Config {
    #[serde(default = "default_position")]
    pub position: String,
    
    #[serde(default = "default_window_transition")]
    pub window_transition: String,
    
    #[serde(default = "default_transition_duration")]
    pub window_transition_duration: u32,
    
    #[serde(default = "default_stack_transition")]
    pub stack_transition: String,
    
    #[serde(default = "default_transition_duration")]
    pub stack_transition_duration: u32,
    
    #[serde(default = "default_margin")]
    pub margin_top: i32,
    
    #[serde(default = "default_margin")]
    pub margin_right: i32,
    
    #[serde(default = "default_margin")]
    pub margin_bottom: i32,
    
    #[serde(default = "default_margin")]
    pub margin_left: i32,
}

fn default_position() -> String { "center".to_string() }
fn default_window_transition() -> String { "slidedown".to_string() }
fn default_stack_transition() -> String { "slidehorizontal".to_string() }
fn default_transition_duration() -> u32 { 200 }
fn default_margin() -> i32 { 10 }

impl Default for Config {
    fn default() -> Self {
        Self {
            position: default_position(),
            window_transition: default_window_transition(),
            window_transition_duration: default_transition_duration(),
            stack_transition: default_stack_transition(),
            stack_transition_duration: default_transition_duration(),
            margin_top: default_margin(),
            margin_right: default_margin(),
            margin_bottom: default_margin(),
            margin_left: default_margin(),
        }
    }
}

impl Config {
    pub fn load() -> Self {
        let config_path = match Self::config_path() {
            Some(p) => p,
            None => return Self::default(),
        };
        
        if config_path.exists() {
            match std::fs::read_to_string(&config_path) {
                Ok(content) => {
                    match toml::from_str(&content) {
                        Ok(config) => {
                            return config;
                        }
                        Err(e) => {
                            eprintln!("Failed to parse config: {}", e);
                        }
                    }
                }
                Err(e) => {
                    eprintln!("Failed to read config: {}", e);
                }
            }
        }
        
        Self::default()
    }
    
    pub fn config_path() -> Option<PathBuf> {
        // Use XDG_CONFIG_HOME if available, fall back to traditional ~/.config
        let config_dir = if let Ok(xdg_config) = std::env::var("XDG_CONFIG_HOME") {
            PathBuf::from(xdg_config)
        } else {
            let home = std::env::var("HOME").ok()?;
            PathBuf::from(home).join(".config")
        };
        
        let user_config = config_dir.join("orbit").join("config.toml");
        
        // NixOS-specific: Fall back to system-wide config if user config doesn't exist
        if Self::is_nixos() && !user_config.exists() {
            let system_config = PathBuf::from("/etc/orbit/config.toml");
            if system_config.exists() {
                return Some(system_config);
            }
        }
        
        Some(user_config)
    }
    
    fn is_nixos() -> bool {
        std::path::Path::new("/etc/NIXOS").exists()
    }
}
