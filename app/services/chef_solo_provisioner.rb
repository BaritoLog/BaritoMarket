require 'open3'

class ChefSoloProvisioner
  attr_accessor :chef_repo_dir

  def initialize(chef_repo_dir, opts = {})
    @chef_repo_dir = chef_repo_dir
    @nodes_dir = opts[:nodes_dir] || File.join(@chef_repo_dir, "nodes")
    @bootstrap_version = opts[:bootstrap_version] || "14.1.1"
  end

  def provision!(host, username, opts = {})
    opts[:attrs] ||= {run_list: []}

    tmp_file = "/tmp/#{SecureRandom.uuid}.json"
    File.open(tmp_file, 'w+') { |f| 
      f.flock(File::LOCK_EX)
      f.puts(opts[:attrs].to_json) 
    }

    # Construct command stack
    cmd_stack = []
    cmd_stack << "cd #{@chef_repo_dir} &&"
    cmd_stack << "knife solo bootstrap"
    cmd_stack << "--bootstrap-version=#{@bootstrap_version}"
    (cmd_stack << "-i #{opts[:private_key]}") if opts[:private_key].present?
    cmd_stack << "#{username}@#{host}"
    cmd_stack << "#{tmp_file}"

    stdout_str, error_str, status = Open3.capture3(cmd_stack.join(' '))
    
    # Put node json file
    node_file = "#{@nodes_dir}/#{host}.json"
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
end
