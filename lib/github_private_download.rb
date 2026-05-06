# frozen_string_literal: true

require "download_strategy"

# Resolves GitHub token from HOMEBREW_GITHUB_API_TOKEN or `gh auth token`.
# Downloads release assets and source archives from private GitHub repos.
# Converts release download URLs into API asset URLs, and
# `archive/refs/tags/<tag>.tar.gz` URLs into API tarball URLs.
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

    accept_header = "Accept: application/octet-stream"

    case url
    when %r{github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(.+)$}
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
    when %r{github\.com/([^/]+)/([^/]+)/archive/refs/tags/(.+)\.tar\.gz$}
      owner = ::Regexp.last_match(1)
      repo = ::Regexp.last_match(2)
      tag = ::Regexp.last_match(3)
      api_url = "https://api.github.com/repos/#{owner}/#{repo}/tarball/#{tag}"
      accept_header = "Accept: application/vnd.github+json"
    else
      api_url = url
    end

    curl_download(
      api_url,
      "--header", accept_header,
      "--header", "Authorization: token #{token}",
      to:      temporary_path,
      timeout: timeout
    )
  end
end
