require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class OpensshService
      class Fedora < Chef::Provider::OpensshService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'fedora pattern' do

            package 'openssh-server' do
              action :install
            end

            template '/etc/ssh/sshd_config' do
              if new_resource.template_source.nil?
                source 'sshd_config.erb'
                cookbook 'openssh'
              else
                source new_resource.template_source
              end
              owner 'root'
              mode '0644'
              variables(:config => new_resource)
              notifies :restart, 'service[sshd]'
              action :create
            end

            service 'sshd' do
              provider Chef::Provider::Service::Systemd
              action [:start, :enable]
            end

          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :fedora, :resource => :openssh_service, :provider => Chef::Provider::OpensshService::Fedora
