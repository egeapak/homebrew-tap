# frozen_string_literal: true

class Mergers < Formula
  desc "CLI/TUI tool for Azure DevOps pull request merging via cherry-picking"
  homepage "https://github.com/egeapak/mergers"
  url "https://github.com/egeapak/mergers/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "c6bcb32abc4fb51ed5f49408f506f199df073d62509287f5163a0b5e78bc1106"
  license "MIT"

  depends_on "git"

  on_macos do
    on_arm do
      url "https://github.com/egeapak/mergers/releases/download/v1.0.0/mergers-aarch64-apple-darwin.tar.gz"
      sha256 "c2e0a46cc5d44d310454de16a72fe18fc6467eab97cef77b177f03f4f9a513ab"
    end

    on_intel do
      url "https://github.com/egeapak/mergers/releases/download/v1.0.0/mergers-x86_64-apple-darwin.tar.gz"
      sha256 "b18935608cbd37a0c5cc68448076f47fa2849aeb37ea0ef06b262c039929da0b"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/egeapak/mergers/releases/download/v1.0.0/mergers-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "8edbfb315f91f4b68fe2af11f58b4e00a4e2f45f9c9a820e4f4d865e94cee937"
    end
  end

  def install
    bin.install "mergers"

    # Ad-hoc re-sign to avoid macOS Gatekeeper blocking the binary
    return unless OS.mac?

    system "codesign", "--remove-signature", "#{bin}/mergers"
    system "codesign", "--force", "--sign", "-", "#{bin}/mergers"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mergers --version")
  end
end
