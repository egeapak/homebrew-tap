# frozen_string_literal: true

require_relative "../lib/github_private_download"

class Mergers < Formula
  desc "CLI/TUI tool for Azure DevOps pull request merging via cherry-picking"
  homepage "https://github.com/egeapak/mergers"
  version "1.1.0"
  license "MIT"

  depends_on "git"

  on_macos do
    on_arm do
      url "https://github.com/egeapak/mergers/releases/download/v1.1.0/mergers-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateDownload
      sha256 "22ebe50eb818e81904f8cad3219c0f78abe36d74e95c16de564efb028eb4a21c"
    end

    on_intel do
      url "https://github.com/egeapak/mergers/releases/download/v1.1.0/mergers-x86_64-apple-darwin.tar.gz",
          using: GitHubPrivateDownload
      sha256 "d67e27d0b082bec49ccbe2b891bcfdd30f5d40f09e4791dc09cc0a13c8197493"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/egeapak/mergers/releases/download/v1.1.0/mergers-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateDownload
      sha256 "bef4e5be674a37eedcaf94dfcb4ed4f4f971e1201ce5ce300ce1410b7c5e6616"
    end
  end

  def install
    bin.install "mergers"

    # Ad-hoc re-sign to avoid macOS Gatekeeper blocking the binary
    return unless OS.mac?

    system "codesign", "--remove-signature", "#{bin}/mergers"
    system "codesign", "--force", "--sign", "-", "#{bin}/mergers"
  end

  def caveats
    <<~EOS
      This formula downloads from a private GitHub repository.
      Authentication is resolved automatically via `gh auth login`.
      If gh is not installed, set HOMEBREW_GITHUB_API_TOKEN instead.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mergers --version")
  end
end
