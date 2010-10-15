#!/usr/bin/env ruby

TMP_MESSAGE_PATH = '/tmp/message'

def branch_from_dir(dir_path, branch_name)
  # get the tree for common
  output = `git ls-tree -d master #{dir_path}`
  dir_sha = output.split(' ')[2]

  command = "git commit-tree #{dir_sha}"

  #
  # See if there is an existing branch
  #
  branch_name_ref = "refs/heads/#{branch_name}"
  parent = `git rev-parse --verify #{branch_name_ref} 2>&1`.strip

  if $?.to_i == 0
    #
    # There is an existing branch
    #
    commit_items = `git cat-file -p #{parent}`.split(' ')
    raise 'should be tree' if commit_items[0] != 'tree'
    parent_tree = commit_items[1]

    #
    # If its tree matches, nothing has changed
    #  - noop
    #
    if parent_tree == dir_sha
      puts "There have been no changes to '#{dir_path}' since the last commit"
      return
    end
    command << " -p #{parent}"
    verb = 'updated'
  else
    verb = 'created'
  end

  master_commit = `git rev-parse master`[0..7]
  File.open(TMP_MESSAGE_PATH, 'w') do |f|
    f.puts "Contents of #{dir_path} from commit #{master_commit}"
  end

  command << " < #{TMP_MESSAGE_PATH}"

  output = `#{command}`
  puts "Created new commit: #{output}"
  `git update-ref #{branch_name_ref} #{output}`
  puts "Branch '#{branch_name}' #{verb}"
end

Dir.glob('PixelLab.*/').collect{ |d| d.chop }.each do |d|
  branch_from_dir(d,d)
end
