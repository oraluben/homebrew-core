class Jenkins < Formula
  desc "Extendable open source continuous integration server"
  homepage "https://www.jenkins.io/"
  url "https://get.jenkins.io/war/2.405/jenkins.war"
  sha256 "6f60864e8baa0e3f61a7d0640a0217718a8b06e7eb91971e11c20c479e64371f"
  license "MIT"

  livecheck do
    url "https://www.jenkins.io/download/"
    regex(%r{href=.*?/war/v?(\d+(?:\.\d+)+)/jenkins\.war}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "0cfd9e231f7f84c541ab12367c2be498eaa91f474a0913010198b0d9db8fbcd0"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "0cfd9e231f7f84c541ab12367c2be498eaa91f474a0913010198b0d9db8fbcd0"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "0cfd9e231f7f84c541ab12367c2be498eaa91f474a0913010198b0d9db8fbcd0"
    sha256 cellar: :any_skip_relocation, ventura:        "0cfd9e231f7f84c541ab12367c2be498eaa91f474a0913010198b0d9db8fbcd0"
    sha256 cellar: :any_skip_relocation, monterey:       "0cfd9e231f7f84c541ab12367c2be498eaa91f474a0913010198b0d9db8fbcd0"
    sha256 cellar: :any_skip_relocation, big_sur:        "0cfd9e231f7f84c541ab12367c2be498eaa91f474a0913010198b0d9db8fbcd0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "59169c0c9cfc9c7cb99dffd2370e90d1330d2ddc3c51de37d35a26e9fc9515a5"
  end

  head do
    url "https://github.com/jenkinsci/jenkins.git", branch: "master"
    depends_on "maven" => :build
  end

  depends_on "openjdk@17"

  def install
    if build.head?
      system "mvn", "clean", "install", "-pl", "war", "-am", "-DskipTests"
    else
      system "#{Formula["openjdk@17"].opt_bin}/jar", "xvf", "jenkins.war"
    end
    libexec.install Dir["**/jenkins.war", "**/cli-#{version}.jar"]
    bin.write_jar_script libexec/"jenkins.war", "jenkins", java_version: "17"
    bin.write_jar_script libexec/"cli-#{version}.jar", "jenkins-cli", java_version: "17"

    (var/"log/jenkins").mkpath
  end

  def caveats
    <<~EOS
      Note: When using launchctl the port will be 8080.
    EOS
  end

  service do
    run [opt_bin/"jenkins", "--httpListenAddress=127.0.0.1", "--httpPort=8080"]
    keep_alive true
    log_path var/"log/jenkins/output.log"
    error_log_path var/"log/jenkins/error.log"
  end

  test do
    ENV["JENKINS_HOME"] = testpath
    ENV.prepend "_JAVA_OPTIONS", "-Djava.io.tmpdir=#{testpath}"

    port = free_port
    fork do
      exec "#{bin}/jenkins --httpPort=#{port}"
    end
    sleep 60

    output = shell_output("curl localhost:#{port}/")
    assert_match(/Welcome to Jenkins!|Unlock Jenkins|Authentication required/, output)
  end
end
