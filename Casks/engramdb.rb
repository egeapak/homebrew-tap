# frozen_string_literal: true

require_relative "../lib/github_private_download"

cask "engramdb" do
  on_macos do
    arch arm: "aarch64", intel: "x86_64"

    version "0.7.0"
    sha256 arm:   "45dfc3069eda7ec840b0d08939ad0750bf9dd9b4722cc6b327261893775bb8e7",
           intel: "e50a1e91e96fa37d040b44175ac0e8f459b8139e008136b08cd430d939880375"

    url "https://github.com/egeapak/engramdb/releases/download/v#{version}/engramdb-#{arch}-apple-darwin.tar.gz",
        using: GitHubPrivateDownload

    binary "engramdb"
  end

  postflight do
    # Remove quarantine and ad-hoc re-sign to pass macOS Gatekeeper checks
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", staged_path]
    binary_path = "#{staged_path}/engramdb"
    system_command "codesign", args: ["--remove-signature", binary_path]
    system_command "codesign", args: ["--force", "--sign", "-", binary_path]
  end

  name "EngramDB"
  desc "Project-scoped persistent memory store for coding agents"
  homepage "https://github.com/egeapak/engramdb"

  caveats <<~EOS
    To use EngramDB with Claude Code:

    1. Set up global Claude Code integration (hooks, MCP, agent directives):

       engramdb setup --global

    2. Initialize a memory store in your project:

       cd your-project && engramdb init

    3. Verify the setup:

       engramdb doctor

    Note: This cask downloads from a private GitHub repository.
    Authentication is resolved automatically via `gh auth login`.
    If gh is not installed, set HOMEBREW_GITHUB_API_TOKEN instead.
  EOS
end
