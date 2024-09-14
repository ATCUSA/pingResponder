#!/bin/bash

# Function to check if Rust is installed
check_rust() {
  if command -v rustc &> /dev/null; then
    echo "Rust is already installed."
  else
    echo "Rust is not installed. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
  fi
}

# Function to install required Rust components
install_rust_components() {
  rustup update
  rustup component add clippy rustfmt
}

# Function to check for cargo
check_cargo() {
  if command -v cargo &> /dev/null; then
    echo "Cargo is installed."
  else
    echo "Cargo is not installed. Cannot proceed."
    exit 1
  fi
}

# Run the functions
check_rust
install_rust_components
check_cargo

echo "Development environment setup is complete."
