# frozen_string_literal: true

# The clove release that `clove` and its plugin formulae install from. Every
# formula points at the same archive, so Homebrew's download cache (keyed by URL)
# lets a plugin reuse the archive `clove` already fetched; each formula then keeps
# only its own binaries. Bump `version` and the checksums here, in one place.
module CloveRelease
  VERSION = "0.2.0"

  SHA256 = {
    "macos-aarch64" => "56990eff8ff0953e0f8d0b5b7dcc0f8d3a0948e9336b376e4603b1b062d36167",
    "macos-x86_64"  => "bf4f19b437620743ef964aaa2b03f1a7efcdbc8d5f615a1d34a6dfbecb8f0b3d",
    "linux-x86_64"  => "b7477aced140e8cbe8b211cc46eb716f220629818a1e31d961e05a9d39d73289",
  }.freeze

  def clove_release
    # Linux x86_64 is the default; macOS overrides it below.
    clove_archive "linux-x86_64"

    on_macos do
      on_arm { clove_archive "macos-aarch64" }
      on_intel { clove_archive "macos-x86_64" }
    end

    # No arm64 Linux build: refuse to install there instead of having no URL.
    on_linux do
      depends_on arch: :x86_64
    end
  end

  def clove_archive(target)
    url "https://github.com/egeapak/clove/releases/download/v#{VERSION}/clove-v#{VERSION}-#{target}.tar.gz"
    sha256 SHA256.fetch(target)
  end

  # Installs `binaries` from the archive into `formula`'s bin, ad-hoc re-signing
  # them on macOS so Gatekeeper does not block the unsigned binaries.
  def self.install(formula, binaries)
    formula.bin.install binaries
    return unless OS.mac?

    binaries.each do |binary|
      formula.system "codesign", "--remove-signature", formula.bin/binary
      formula.system "codesign", "--force", "--sign", "-", formula.bin/binary
    end
  end
end
