# frozen_string_literal: true

require_relative "../lib/clove_release"

class Clove < Formula
  extend CloveRelease

  desc "Fast, git-native, dependency-aware work-item tracker"
  homepage "https://github.com/egeapak/clove"
  license "AGPL-3.0-only"

  clove_release

  uses_from_macos "zlib" # cloved links libz.so.1 on Linux

  on_linux do
    depends_on "patchelf" => :build
  end

  def install
    CloveRelease.install(self, %w[clove cloved])

    # The prebuilt cloved has no RPATH, so it would load the system libz instead
    # of the zlib dependency; Homebrew only relocates RPATHs that already exist.
    system "patchelf", "--set-rpath", formula_opt_lib("zlib"), bin/"cloved" if OS.linux?
  end

  def caveats
    <<~EOS
      To track work in a repository:

        cd your-project && clove init

      To let Claude Code use clove (MCP server + agent directives):

        clove setup            # this project, or `clove setup --global`

      Integrations are separate formulae:

        brew install clove-sync-github    # two-way GitHub Issues sync
        brew install clove-import-tk      # import from tk
        brew install clove-import-beads   # import/export Beads
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clove version")
    assert_match version.to_s, shell_output("#{bin}/cloved --version")

    system bin/"clove", "init"
    system bin/"clove", "new", "brew test item"
    assert_match "brew test item", shell_output("#{bin}/clove ls")
  end
end
