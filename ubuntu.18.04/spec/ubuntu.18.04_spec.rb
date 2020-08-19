require 'spec_helper'

describe command('pwsh --version') do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/PowerShell 7.0.3/) }
end

describe command("pwsh -c '[Reflection.AssemblyName]::GetAssemblyName(\"/Octopus.Client.dll\").Version.ToString()'") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/8.8.3.0/) }
end

describe command("pwsh -c '(Get-Module Az -ListAvailable).Version.ToString()'") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/4.5.0/) }
end

describe command('dotnet --version') do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/3.1.401/) }
end

describe command('java --version') do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/11.0.8/) }
end

describe command('az --version') do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/2.10.1/) }
end

describe command('aws --version') do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/1.18/) }
end

describe command('node --version') do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/v12.18.3/) }
end

describe command('kubectl version') do
  its(:stdout) { should contain(/v1.18.8/) }
end

describe command("helm version") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/v3.3.0/)}
end

describe command("terraform version") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/Terraform v0.13.0/)}
end

describe "python" do
  describe command("python --version") do
    its(:exit_status) { should eq(0) }
    # python 2 prints it's version to stderr, for some reason
    its(:stderr) { should contain(/Python 2.7.17/)}
  end

  describe command("python3 --version") do
    its(:exit_status) { should eq(0) }
    its(:stdout) { should contain(/Python 3.6.9/)}
  end
end

describe command("gcloud --version") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/2020/)}
end

describe command("octo --version") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/7.4.1/)}
end

describe command("eksctl version") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/0.25.0/)}
end

describe command("ecs-cli --version") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/1.20.0/)}
end

describe command("mvn --version") do
  its(:exit_status) { should eq(0) }
end

describe command("gradle --version") do
  its(:exit_status) { should eq(0) }
end

describe command("aws-iam-authenticator version") do
  its(:exit_status) { should eq(0) }
  its(:stdout) { should contain(/v0.5.1/)}
end

describe command("istioctl version") do
  its(:exit_status) { should eq(0) }
end

describe command("linkerd version") do
  its(:exit_status) { should eq(0) }
end

describe command("skopeo --version") do
  its(:exit_status) { should eq(0) }
end

describe command("umoci --version") do
  its(:exit_status) { should eq(0) }
end
