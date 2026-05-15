# frozen_string_literal: true

require_relative "../lib/github_private_download"

cask "engramdb" do
  on_macos do
    arch arm: "aarch64", intel: "x86_64"

    version "0.6.0"
    sha256 arm:   "c6a56631e4519469ce587721567c9deaeae4c58ac109d3f443b0aceaeac510fe",
           intel: "37d7ef06838173985949f2a441f7742ca86aba8b708e55f3e9cfabe136f54a17"

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
