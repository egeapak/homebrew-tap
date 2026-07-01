# frozen_string_literal: true

require_relative "../lib/github_private_download"

class Engramdb < Formula
  desc "Project-scoped persistent memory store for coding agents"
  homepage "https://github.com/egeapak/engramdb"
  version "0.8.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/egeapak/engramdb/releases/download/v#{version}/engramdb-aarch64-apple-darwin.tar.gz",
          using: GitHubPrivateDownload
      sha256 "eedf77d6b6e77bcb70dbb0b8009bf2e6f1baa866df6e9e404bc08fbe41d26de1"
    end

    on_intel do
      url "https://github.com/egeapak/engramdb/releases/download/v#{version}/engramdb-x86_64-apple-darwin.tar.gz",
          using: GitHubPrivateDownload
      sha256 "a9975f6cfd7fe7fcde73275d7f9daafc30d3c24ca7944c983ad6effd6d49f43e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/egeapak/engramdb/releases/download/v#{version}/engramdb-x86_64-unknown-linux-gnu.tar.gz",
          using: GitHubPrivateDownload
      sha256 "0579e186cbceee06d1f5c98f68b7a772e6d8145f2ea69ab4694b2219a5fc289d"
    end
  end

  def install
    if OS.mac? && Hardware::CPU.intel?
      # The intel-macOS tarball ships a dynamically-linked ONNX Runtime
      # (rpath @executable_path) alongside the binary; keep them together in
      # libexec and expose the binary via a symlink in bin.
      libexec.install "engramdb", *Dir["libonnxruntime*.dylib"]
      bin.install_symlink libexec/"engramdb"
      signed = libexec/"engramdb"
    else
      # arm-macOS and Linux binaries statically link ONNX Runtime and are
      # self-contained.
      bin.install "engramdb"
      signed = bin/"engramdb"
    end

    # Ad-hoc re-sign to avoid macOS Gatekeeper blocking the unsigned binary.
    return unless OS.mac?

    system "codesign", "--remove-signature", signed
    system "codesign", "--force", "--sign", "-", signed
  end

  def caveats
    <<~EOS
      To use EngramDB with Claude Code:

      1. Set up global Claude Code integration (hooks, MCP, agent directives):

         engramdb setup --global

      2. Initialize a memory store in your project:

         cd your-project && engramdb init

      3. Verify the setup:

         engramdb doctor

      This formula downloads from a private GitHub repository.
      Authentication is resolved automatically via `gh auth login`.
      If gh is not installed, set HOMEBREW_GITHUB_API_TOKEN instead.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/engramdb --version")
  end
end
