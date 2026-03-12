# frozen_string_literal: true

require "download_strategy"

# Resolves GitHub token from HOMEBREW_GITHUB_API_TOKEN or `gh auth token`.
# Downloads release assets from private GitHub repos.
# Converts the human-readable release URL into an API asset URL and
# authenticates with HOMEBREW_GITHUB_API_TOKEN or `gh auth token`.
class GitHubPrivateDownload < CurlDownloadStrategy
  def _fetch(url:, resolved_url:, timeout:)
    token = ENV["HOMEBREW_GITHUB_API_TOKEN"].to_s
    if token.empty?
      gh_path = which("gh") || "#{HOMEBREW_PREFIX}/bin/gh"
      token = `#{gh_path} auth token 2>/dev/null`.strip if File.executable?(gh_path.to_s)
    end

    if token.empty?
      raise CurlDownloadStrategyError, <<~EOS
        No GitHub credentials found for private repo download.
        Authenticate with: gh auth login
        Or set: export HOMEBREW_GITHUB_API_TOKEN=<your-token>
      EOS
    end

    # Convert release download URL to API asset URL.
    # e.g. github.com/owner/repo/releases/download/v1.0/file.tar.gz
    #   -> api.github.com/repos/owner/repo/releases/tags/v1.0 -> asset ID
    if url =~ %r{github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(.+)$}
      owner = ::Regexp.last_match(1)
      repo = ::Regexp.last_match(2)
      tag = ::Regexp.last_match(3)
      filename = ::Regexp.last_match(4)
      require "json"
      release_json = `curl -sf -H "Authorization: token #{token}" https://api.github.com/repos/#{owner}/#{repo}/releases/tags/#{tag}`
      release = JSON.parse(release_json)
      asset = release["assets"]&.find { |a| a["name"] == filename }

      raise CurlDownloadStrategyError, "Asset '#{filename}' not found in release #{tag}" unless asset

      api_url = "https://api.github.com/repos/#{owner}/#{repo}/releases/assets/#{asset["id"]}"
    else
      api_url = url
    end

    curl_download(
      api_url,
      "--header", "Accept: application/octet-stream",
      "--header", "Authorization: token #{token}",
      to:      temporary_path,
      timeout: timeout
    )
  end
end

cask "engramdb" do
  on_macos do
    arch arm: "aarch64", intel: "x86_64"

    version "0.3.0"
    sha256 arm:   "428a711a71f15c41db35c4ecadb7ac1b61b1cb1e422bfed7b5195d6c6342b098",
           intel: "3ec234ade568e49cae5b6039aba87d7099e89fdc1ff4d4a8f8f2fe5bdf53ed4f"

    url "https://github.com/egeapak/engramdb/releases/download/v#{version}/engramdb-#{arch}-apple-darwin.tar.gz",
        using: GitHubPrivateDownload

    binary "engramdb"

    postflight do
      # Ad-hoc re-sign to avoid macOS Gatekeeper blocking the binary
      binary_path = "#{staged_path}/engramdb"
      system_command "codesign", args: ["--remove-signature", binary_path]
      system_command "codesign", args: ["--force", "--sign", "-", binary_path]
    end
  end

  name "EngramDB"
  desc "Project-scoped persistent memory store for coding agents"
  homepage "https://github.com/egeapak/engramdb"

  caveats <<~EOS
    To use EngramDB with Claude Code:

    1. Install the Claude Code plugin (sets up MCP server + hooks automatically):

       claude plugin marketplace add egeapak/engramdb
       claude plugin install engramdb@engramdb

    2. Initialize a memory store in your project:

       cd your-project && engramdb init

    3. Verify the setup:

       engramdb doctor

    For manual setup without the plugin, see the project README.

    Note: This cask downloads from a private GitHub repository.
    Authentication is resolved automatically via `gh auth login`.
    If gh is not installed, set HOMEBREW_GITHUB_API_TOKEN instead.
  EOS
end
