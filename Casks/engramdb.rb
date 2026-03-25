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
