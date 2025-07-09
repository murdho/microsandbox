//! Ruby engine implementation for code execution in a sandboxed environment.
//!
//! This module provides a Ruby-based code execution engine that:
//! - Runs Ruby code in an interactive subprocess
//! - Captures and streams stdout/stderr output
//! - Manages process lifecycle and cleanup
//! - Provides non-blocking evaluation of Ruby code
//!
//! The engine uses Ruby's IRB (Interactive Ruby) with customized settings to
//! disable prompts and ensure proper output handling for real-time streaming.

use async_trait::async_trait;
use std::sync::{Arc, Mutex};
use tokio::{
    io::{AsyncBufReadExt, AsyncWriteExt, BufReader},
    process::Command,
    sync::{
        mpsc::{self, Sender},
        oneshot,
    },
    time::{sleep, Duration},
};

use super::types::{Engine, EngineError, Resp, Stream};

//--------------------------------------------------------------------------------------------------
// Types
//--------------------------------------------------------------------------------------------------

/// Ruby engine implementation using subprocess
pub struct RubyEngine {
    process_control_tx: Option<Sender<ProcessControl>>,
    eval_tx: Option<Sender<EvalRequest>>,
}

/// Commands for controlling the Ruby process
enum ProcessControl {
    Shutdown,
}

/// Request for code evaluation
struct EvalRequest {
    id: String,
    code: String,
    resp_tx: Sender<Resp>,
    done_tx: oneshot::Sender<Result<(), EngineError>>,
    timeout: Option<u64>,
}

//--------------------------------------------------------------------------------------------------
// Implementation
//--------------------------------------------------------------------------------------------------

impl Default for RubyEngine {
    fn default() -> Self {
        Self::new()
    }
}

impl RubyEngine {
    /// Create a new Ruby engine instance
    pub fn new() -> Self {
        Self {
            process_control_tx: None,
            eval_tx: None,
        }
    }
}

#[async_trait]
impl Engine for RubyEngine {
    /// Initialize the Ruby engine and start the interactive subprocess
    async fn initialize(&mut self) -> Result<(), EngineError> {
        tracing::debug!("Initializing Ruby engine");

        // Create channels for communication
        let (process_control_tx, mut process_control_rx) = mpsc::channel::<ProcessControl>(10);
        let (eval_tx, mut eval_rx) = mpsc::channel::<EvalRequest>(10);

        self.process_control_tx = Some(process_control_tx);
        self.eval_tx = Some(eval_tx);

        // Spawn the Ruby process management task
        tokio::spawn(async move {
            let mut child = match Command::new("ruby")
                .arg("-e")
                .arg(r#"
                    # Disable buffering and configure for non-interactive mode
                    $stdout.sync = true
                    $stderr.sync = true
                    
                    # Disable IRB prompts and warnings  
                    $VERBOSE = nil
                    
                    # Custom evaluation with proper error handling
                    def safe_eval(code)
                      begin
                        result = eval(code)
                        puts "EVAL_RESULT: #{result.inspect}" unless result.nil?
                      rescue => e
                        $stderr.puts "ERROR: #{e.class}: #{e.message}"
                        $stderr.puts e.backtrace.join("\n") if e.backtrace
                      end
                    end
                    
                    # Read and evaluate code from stdin
                    while line = gets
                      marker = line.strip
                      if marker.start_with?('EVAL_START:')
                        eval_id = marker.split(':', 2)[1]
                        code_lines = []
                        while (code_line = gets) && !code_line.strip.start_with?('EVAL_END:')
                          code_lines << code_line
                        end
                        
                        code = code_lines.join
                        puts "EVAL_BEGIN:#{eval_id}"
                        safe_eval(code) unless code.strip.empty?
                        puts "EVAL_COMPLETE:#{eval_id}"
                      end
                    end
                "#)
                .stdin(std::process::Stdio::piped())
                .stdout(std::process::Stdio::piped())
                .stderr(std::process::Stdio::piped())
                .spawn()
            {
                Ok(child) => child,
                Err(e) => {
                    tracing::error!("Failed to spawn Ruby process: {}", e);
                    return;
                }
            };

            let mut stdin = child.stdin.take().unwrap();
            let stdout = child.stdout.take().unwrap();
            let stderr = child.stderr.take().unwrap();

            // Create readers for stdout and stderr
            let stdout_reader = BufReader::new(stdout);
            let stderr_reader = BufReader::new(stderr);

            // Shared state for tracking evaluations
            let current_eval: Arc<Mutex<Option<(String, Sender<Resp>)>>> =
                Arc::new(Mutex::new(None));

            // Spawn stdout handler
            let stdout_eval = current_eval.clone();
            tokio::spawn(async move {
                let mut lines = stdout_reader.lines();
                while let Ok(Some(line)) = lines.next_line().await {
                    tracing::debug!("Ruby stdout: {}", line);
                    
                    let eval_context = stdout_eval.lock().unwrap().clone();
                    if let Some((eval_id, resp_tx)) = eval_context {
                        if line.starts_with("EVAL_BEGIN:") {
                            // Evaluation started
                            continue;
                        } else if line.starts_with("EVAL_COMPLETE:") {
                            // Evaluation completed
                            let _ = resp_tx
                                .send(Resp::Done {
                                    id: eval_id.clone(),
                                })
                                .await;
                            continue;
                        } else if line.starts_with("EVAL_RESULT:") {
                            // Skip the EVAL_RESULT prefix for cleaner output
                            let result = line.strip_prefix("EVAL_RESULT: ").unwrap_or(&line);
                            let _ = resp_tx
                                .send(Resp::Line {
                                    id: eval_id.clone(),
                                    stream: Stream::Stdout,
                                    text: result.to_string(),
                                })
                                .await;
                        } else {
                            // Regular output
                            let _ = resp_tx
                                .send(Resp::Line {
                                    id: eval_id.clone(),
                                    stream: Stream::Stdout,
                                    text: line,
                                })
                                .await;
                        }
                    }
                }
            });

            // Spawn stderr handler
            let stderr_eval = current_eval.clone();
            tokio::spawn(async move {
                let mut lines = stderr_reader.lines();
                while let Ok(Some(line)) = lines.next_line().await {
                    tracing::debug!("Ruby stderr: {}", line);
                    
                    let eval_context = stderr_eval.lock().unwrap().clone();
                    if let Some((eval_id, resp_tx)) = eval_context {
                        let _ = resp_tx
                            .send(Resp::Line {
                                id: eval_id.clone(),
                                stream: Stream::Stderr,
                                text: line,
                            })
                            .await;
                    }
                }
            });

            // Main process loop
            loop {
                tokio::select! {
                    // Handle process control commands
                    Some(cmd) = process_control_rx.recv() => {
                        match cmd {
                            ProcessControl::Shutdown => {
                                tracing::debug!("Shutting down Ruby process");
                                let _ = child.kill().await;
                                break;
                            }
                        }
                    }
                    
                    // Handle evaluation requests
                    Some(eval_req) = eval_rx.recv() => {
                        // Set current evaluation context
                        *current_eval.lock().unwrap() = Some((eval_req.id.clone(), eval_req.resp_tx.clone()));
                        
                        // Send evaluation to Ruby process
                        let eval_marker = format!("EVAL_START:{}\n", eval_req.id);
                        let eval_end = format!("EVAL_END:{}\n", eval_req.id);
                        
                        let full_input = format!("{}{}\n{}", eval_marker, eval_req.code, eval_end);
                        
                        match stdin.write_all(full_input.as_bytes()).await {
                            Ok(_) => {
                                match stdin.flush().await {
                                    Ok(_) => {
                                        // Set up timeout if specified
                                        if let Some(timeout_secs) = eval_req.timeout {
                                            let resp_tx = eval_req.resp_tx.clone();
                                            let eval_id = eval_req.id.clone();
                                            let current_eval_timeout = current_eval.clone();
                                            
                                            tokio::spawn(async move {
                                                sleep(Duration::from_secs(timeout_secs)).await;
                                                
                                                // Check if this evaluation is still active
                                                let is_active = current_eval_timeout.lock().unwrap()
                                                    .as_ref()
                                                    .map(|(id, _)| id == &eval_id)
                                                    .unwrap_or(false);
                                                
                                                if is_active {
                                                    let _ = resp_tx.send(Resp::Error {
                                                        id: eval_id.clone(),
                                                        message: format!("Evaluation timeout after {} seconds", timeout_secs),
                                                    }).await;
                                                    
                                                    // Clear the current evaluation
                                                    *current_eval_timeout.lock().unwrap() = None;
                                                }
                                            });
                                        }
                                        
                                        let _ = eval_req.done_tx.send(Ok(()));
                                    }
                                    Err(e) => {
                                        let _ = eval_req.done_tx.send(Err(EngineError::Evaluation(format!("Failed to flush Ruby stdin: {}", e))));
                                    }
                                }
                            }
                            Err(e) => {
                                let _ = eval_req.done_tx.send(Err(EngineError::Evaluation(format!("Failed to write to Ruby stdin: {}", e))));
                            }
                        }
                    }
                }
            }

            // Wait for the process to finish
            let _ = child.wait().await;
            tracing::debug!("Ruby process terminated");
        });

        tracing::debug!("Ruby engine initialized successfully");
        Ok(())
    }

    /// Evaluate Ruby code
    async fn eval(
        &mut self,
        id: String,
        code: String,
        sender: &Sender<Resp>,
        timeout: Option<u64>,
    ) -> Result<(), EngineError> {
        let eval_tx = self
            .eval_tx
            .as_ref()
            .ok_or_else(|| EngineError::Unavailable("Ruby engine not initialized".to_string()))?;

        let (done_tx, done_rx) = oneshot::channel();

        let eval_req = EvalRequest {
            id,
            code,
            resp_tx: sender.clone(),
            done_tx,
            timeout,
        };

        eval_tx
            .send(eval_req)
            .await
            .map_err(|_| EngineError::Unavailable("Ruby engine channel closed".to_string()))?;

        // Wait for the evaluation to be submitted
        done_rx
            .await
            .map_err(|_| EngineError::Evaluation("Ruby evaluation channel closed".to_string()))?
    }

    /// Shutdown the Ruby engine
    async fn shutdown(&mut self) {
        tracing::debug!("Shutting down Ruby engine");

        if let Some(tx) = self.process_control_tx.take() {
            let _ = tx.send(ProcessControl::Shutdown).await;
        }

        self.eval_tx = None;
    }
}

//--------------------------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------------------------

/// Create a new Ruby engine instance
///
/// This function creates a new Ruby engine that can be used to evaluate Ruby code.
/// The engine must be initialized before it can be used.
///
/// # Returns
///
/// A boxed Ruby engine instance implementing the `Engine` trait.
///
/// # Errors
///
/// Returns an `EngineError` if the engine cannot be created.
pub fn create_engine() -> Result<Box<dyn Engine>, EngineError> {
    tracing::debug!("Creating Ruby engine");
    Ok(Box::new(RubyEngine::new()))
}