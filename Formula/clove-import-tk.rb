# frozen_string_literal: true

require_relative "../lib/clove_release"

class CloveImportTk < Formula
  extend CloveRelease

  desc "Import tk tickets into clove"
  homepage "https://github.com/egeapak/clove"
  license "AGPL-3.0-only"

  clove_release

  depends_on "clove"

  def install
    CloveRelease.install(self, %w[clove-import-tk])
  end

  test do
    # Pin resolution to this formula's bin so a copy elsewhere on $PATH can't
    # satisfy the check.
    ENV["CLOVE_PLUGIN_PATH"] = bin
    output = shell_output("#{formula_opt_bin("clove")}/clove --format json plugin list")
    plugin = JSON.parse(output)["data"].find { |entry| entry["name"] == "import-tk" }
    assert_equal (bin/"clove-import-tk").to_s, plugin&.fetch("path")
    assert_equal "ok", plugin&.fetch("status")
  end
end
