control 'container' do
  impact 0.5
  describe docker_container('mysql-router') do
    it { should exist }
    it { should be_running }
    its('repo') { should eq 'mysql/mysql-router' }
    its('ports') { should eq '6446-6447/tcp, 64460/tcp, 64470/tcp' }
    its('command') { should match '/run.sh.*' }
  end
end
control 'packages' do
  impact 0.5
  describe package('mysql-community-server-minimal') do
    it { should be_installed }
    its ('version') { should match '8.0.23.*' }
  end
  describe package('mysql-router-community') do
    it { should be_installed }
    its ('version') { should match '8.0.23.*' }
  end
end
