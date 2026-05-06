# frozen_string_literal: true

require_relative "../lib/github_private_download"

cask "engramdb" do
  on_macos do
    arch arm: "aarch64", intel: "x86_64"

    version "0.4.0"
    sha256 arm:   "6a288389ee656e6c1f1167f68ba85f705b8c49de6e9bd7cf33e30d987040ffe2",
           intel: "9ae43ab85cbd2a46ccbc6800722e5dd8259a8ccd76e470368ac076e71f3c2611"

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
