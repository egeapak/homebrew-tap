# frozen_string_literal: true

class Engramdb < Formula
  desc "Project-scoped persistent memory store for coding agents"
  homepage "https://github.com/egeapak/engramdb"
  version "0.9.0"
  license "MIT"

  # EngramDB ships no ONNX Runtime of its own. The prebuilt that `ort`'s
  # `download-binaries` feature fetches executes quantized models incorrectly on
  # AVX-512/AMX hosts — the same text embeds to unrelated vectors under CPU load,
  # and those vectors get persisted. Homebrew's build is unaffected. As of 0.9.0
  # the release archives contain the binary and nothing else, on every platform.
  #
  # The binary resolves this dependency at *run* time rather than recording it as
  # a load-time dependency. That matters when the guarantee stops holding —
  # `brew uninstall onnxruntime`, a major bump that changes the dylib's install
  # name, a relocated Cellar. A load-time dependency would mean `engramdb` does
  # not start at all: no `--version`, and no `doctor` to explain why. Resolving at
  # run time records nothing, so the binary always starts and degrades to keyword
  # search with an actionable message.
  #
  # Any version providing C API 24 (ONNX Runtime >= 1.24) works; Homebrew
  # currently ships 1.28.
  depends_on "onnxruntime"

  on_macos do
    on_arm do
      url "https://github.com/egeapak/engramdb/releases/download/v#{version}/engramdb-aarch64-apple-darwin.tar.gz"
      sha256 "0a254a0ac4fec3f1deb9cdd297f48608e449ed43266704d14c8f1d9f203fd654"
    end

    on_intel do
      url "https://github.com/egeapak/engramdb/releases/download/v#{version}/engramdb-x86_64-apple-darwin.tar.gz"
      sha256 "98b327187470fbd0d4b6c0c99085f57b117fbc3095cb60cd352242c47b85a4b1"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/egeapak/engramdb/releases/download/v#{version}/engramdb-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "28b6d89fdf534df1bfbfecdc2249443f57d7ab9d09381b5f47758f25a8c02778"
    end
  end

  def install
    # Every archive is just the binary now. Through 0.8.0 the Intel-macOS tarball
    # also carried a `libonnxruntime*.dylib` (rpath @executable_path), which
    # needed a libexec + symlink dance to keep the two together; that is gone.
    bin.install "engramdb"

    # Ad-hoc re-sign to avoid macOS Gatekeeper blocking the unsigned binary.
    return unless OS.mac?

    system "codesign", "--remove-signature", bin/"engramdb"
    system "codesign", "--force", "--sign", "-", bin/"engramdb"
  end

  def caveats
    <<~EOS
      To use EngramDB with Claude Code:

      1. Set up global Claude Code integration (hooks, MCP, agent directives):

         engramdb setup --global

      2. Initialize a memory store in your project:

         cd your-project && engramdb init

      3. Verify the setup, including which ONNX Runtime was resolved:

         engramdb doctor
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/engramdb --version")

    # `doctor` reports the ONNX Runtime it resolved. Proving the dependency is
    # actually wired up is the one thing worth testing here: a formula that
    # silently produced a keyword-only build would otherwise look healthy.
    assert_match "ONNX Runtime", shell_output("#{bin}/engramdb doctor 2>&1")
  end
end
