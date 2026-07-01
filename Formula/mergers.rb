# frozen_string_literal: true

require_relative "../lib/github_private_download"

class Mergers < Formula
  desc "CLI/TUI tool for Azure DevOps pull request merging via cherry-picking"
  homepage "https://github.com/egeapak/mergers"
  version "1.2.0"
  license "MIT"

  depends_on "git"

  on_macos do
    on_arm do
      url "https://github.com/egeapak/mergers/releases/download/v1.2.0/mergers-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateDownload
      sha256 "2dd391af21b0343951a33f86afe46473963664dddd9c33ee9ff567dd9dbb0f2c"
    end

    on_intel do
      url "https://github.com/egeapak/mergers/releases/download/v1.2.0/mergers-x86_64-apple-darwin.tar.gz",
          using: GitHubPrivateDownload
      sha256 "3c98054eec7a580ac43dde936ed3f9aeb2d4ffbfce5374e10bf2628cff3579fd"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/egeapak/mergers/releases/download/v1.2.0/mergers-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateDownload
      sha256 "8baea54ac075dcd6c1ad0476c9de868812547846a4e7804bcae9e51cea3d2db1"
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
