# Example formula for a Go/Rust binary distributed via GitHub Releases.
# Copy this file, rename it to <project>.rb, and update the values below.
#
# Naming convention:
#   - Class name: CamelCase version of the formula name (e.g., my-tool → MyTool)
#   - File name:  lowercase, hyphens allowed (e.g., my-tool.rb)
#
# After editing, validate with:
#   brew audit --strict Formula/<project>.rb
#   brew install --build-from-source Formula/<project>.rb
#   brew test Formula/<project>.rb

class Example < Formula
  desc "Short description of the project"
  homepage "https://github.com/egeapak/example"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/egeapak/example/releases/download/v#{version}/example-darwin-arm64.tar.gz"
      sha256 "REPLACE_WITH_SHA256_FOR_MACOS_ARM64"
    end

    on_intel do
      url "https://github.com/egeapak/example/releases/download/v#{version}/example-darwin-amd64.tar.gz"
      sha256 "REPLACE_WITH_SHA256_FOR_MACOS_AMD64"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/egeapak/example/releases/download/v#{version}/example-linux-arm64.tar.gz"
      sha256 "REPLACE_WITH_SHA256_FOR_LINUX_ARM64"
    end

    on_intel do
      url "https://github.com/egeapak/example/releases/download/v#{version}/example-linux-amd64.tar.gz"
      sha256 "REPLACE_WITH_SHA256_FOR_LINUX_AMD64"
    end
  end

  def install
    bin.install "example"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/example --version")
  end
end
