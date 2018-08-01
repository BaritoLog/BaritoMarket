require 'open3'

class ChefSoloBootstrapper
  attr_accessor :chef_repo_dir

  def initialize(chef_repo_dir, opts = {})
    @chef_repo_dir = chef_repo_dir
    @nodes_dir = opts[:nodes_dir] || File.join(@chef_repo_dir, "nodes")
    @bootstrap_version = opts[:bootstrap_version] || "14.1.1"
  end

  def bootstrap!(host_name, host_ipaddress, username, opts = {})
    opts[:attrs] ||= {run_list: []}

    tmp_file = "/tmp/#{SecureRandom.uuid}.json"
    File.open(tmp_file, 'w+') { |f|
      f.flock(File::LOCK_EX)
      f.puts(opts[:attrs].to_json)
    }

    # Remove box ip address from known_hosts
    # TODO: Should find more secure ways
    known_hosts_status = remove_known_hosts!(host_ipaddress)
    return known_hosts_status unless known_hosts_status['success'] == true

    # Do bootstrap
    cmd_stack = []
    cmd_stack << "cd #{@chef_repo_dir}"
    cmd_stack << "&& knife solo bootstrap"
    cmd_stack << "--bootstrap-version=#{@bootstrap_version}"
    (cmd_stack << "-i #{opts[:private_key]}") if opts[:private_key].present?
    cmd_stack << "#{username}@#{host_ipaddress || host_name}"
    cmd_stack << "#{tmp_file}"

    stdout_str, error_str, status = Open3.capture3(cmd_stack.join(' '))

    # Put node json file
    node_file = "#{@nodes_dir}/#{host_name}.json"
    FileUtils.cp tmp_file, node_file
    FileUtils.rm tmp_file

    if status.success?
      return {
        'success' => true
      }
    else
      return {
        'success' => false,
        'error' => error_str,
        'error_log' => stdout_str
      }
    end
  end

  def remove_known_hosts!(host_ipaddress)
    shell_user, error_str, status = Open3.capture3('whoami')

    cmd_stack = []
    if shell_user == 'root'
      cmd_stack << "ssh-keygen -f '/root/.ssh/known_hosts' -R #{host_ipaddress}"
    else
      cmd_stack << "ssh-keygen -f '/home/#{shell_user}/.ssh/known_hosts' -R #{host_ipaddress}"
    end

    stdout_str, error_str, status = Open3.capture3(cmd_stack.join(' '))
    
    if status.success?
      return {
        'success' => true
      }
    else
      return {
        'success' => false,
        'error' => error_str,
        'error_log' => stdout_str
      }
    end
  end
end
