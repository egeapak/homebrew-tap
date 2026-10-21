# frozen_string_literal: true

require_relative "../lib/clove_release"

class CloveSyncGithub < Formula
  extend CloveRelease

  desc "Two-way GitHub Issues sync for clove"
  homepage "https://github.com/egeapak/clove"
  license "AGPL-3.0-only"

  clove_release

  depends_on "clove"

  def install
    CloveRelease.install(self, %w[clove-sync-github])
  end

  test do
    # Pin resolution to this formula's bin so a copy elsewhere on $PATH can't
    # satisfy the check.
    ENV["CLOVE_PLUGIN_PATH"] = bin
    output = shell_output("#{formula_opt_bin("clove")}/clove --format json plugin list")
    plugin = JSON.parse(output)["data"].find { |entry| entry["name"] == "sync-github" }
    assert_equal (bin/"clove-sync-github").to_s, plugin&.fetch("path")
    assert_equal "ok", plugin&.fetch("status")
  end
end
