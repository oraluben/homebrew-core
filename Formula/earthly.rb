class Earthly < Formula
  desc "Build automation tool for the container era"
  homepage "https://earthly.dev/"
  url "https://github.com/earthly/earthly.git",
      tag:      "v0.7.5",
      revision: "0857e35cefb1a0155638f47b3ac0558844b48c3f"
  license "MPL-2.0"
  head "https://github.com/earthly/earthly.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "7b157181ab3cd46e1b28cafd1c52ce8996a5303b551a22d769d0849c2cfec9ab"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "7b157181ab3cd46e1b28cafd1c52ce8996a5303b551a22d769d0849c2cfec9ab"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "7b157181ab3cd46e1b28cafd1c52ce8996a5303b551a22d769d0849c2cfec9ab"
    sha256 cellar: :any_skip_relocation, ventura:        "a573c1af71f0fa56cdb2b1b5ca4eda77a95b03100cd623f5c2d96ee4f62843c2"
    sha256 cellar: :any_skip_relocation, monterey:       "a573c1af71f0fa56cdb2b1b5ca4eda77a95b03100cd623f5c2d96ee4f62843c2"
    sha256 cellar: :any_skip_relocation, big_sur:        "a573c1af71f0fa56cdb2b1b5ca4eda77a95b03100cd623f5c2d96ee4f62843c2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "95e8ff492f617f6b2447d4e36b239d0233975c29f19690cfb7664187a190511a"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X main.DefaultBuildkitdImage=earthly/buildkitd:v#{version}
      -X main.Version=v#{version}
      -X main.GitSha=#{Utils.git_head}
      -X main.BuiltBy=homebrew
    ]
    tags = "dfrunmount dfrunsecurity dfsecrets dfssh dfrunnetwork dfheredoc forceposix"
    system "go", "build", "-tags", tags, *std_go_args(ldflags: ldflags), "./cmd/earthly"

    generate_completions_from_executable(bin/"earthly", "bootstrap", "--source", shells: [:bash, :zsh])
  end

  test do
    # earthly requires docker to run; therefore doing a complete end-to-end test here is not
    # possible; however the "earthly ls" command is able to run without docker.
    (testpath/"Earthfile").write <<~EOS
      VERSION 0.6
      mytesttarget:
      \tRUN echo Homebrew
    EOS
    output = shell_output("#{bin}/earthly ls")
    assert_match "+mytesttarget", output
  end
end
