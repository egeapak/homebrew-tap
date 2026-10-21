# frozen_string_literal: true

require_relative "../lib/clove_release"

class Clove < Formula
  extend CloveRelease

  desc "Fast, git-native, dependency-aware work-item tracker"
  homepage "https://github.com/egeapak/clove"
  license "AGPL-3.0-only"

  clove_release

  def install
    CloveRelease.install(self, %w[clove cloved])
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
