require 'open3'

class TagMatic
  VERSION = '0.0.2'

  HASH_BANG       = '#!/bin/bash'

  APP_DIRECTORIES = %w/
    app
    config
    lib
    src
  /

  IGNORE_FILES = %w/
    javascript
    sql
  /

  HOOKS_FILES = %w/
    post-checkout
    post-merge
  /

  attr_accessor :current_dir

  def initialize(*argv)
    command = argv.shift
    command = command.tr('-', '_') if command

    if command && respond_to?(command) && argv
      send(command, argv)
    elsif command && respond_to?(command)
      send(command)
    else
      puts 'Command not found'
      puts help
    end
  end

  def install(*argv)
    HOOKS_FILES.each do |file_name|
      append(File.join(git_dir, 'hooks', file_name), 0777) do |body, f|
        f.puts HASH_BANG unless body
        f.puts 'tagmatic generate-tags .'
      end
    end
    puts 'all tagged up'
  end

  def generate_tags(dir_path)
    raise ArgumentError.new('missing directory') if dir_path.empty?
    puts 'Regenerating tags...'
    self.current_dir = File.expand_path(dir_path.pop)
    remove_tags_file(dir_path)
    APP_DIRECTORIES.each do |path|
      result = `ctags -Ra #{ignore} #{path}` if File.exists?(path)
      unless $?.to_i == 0
        raise RuntimeError, result
      end
    end
  end

  def help
    'Run `tagmatic install` to setup the hooks that regenerate your "tags" file.'
  end

  def __version
    puts VERSION
  end

  protected

  def git_dir
    @git_dir = %x[git rev-parse --git-dir].chomp
    @git_dir
  end

  def append(file, *args)
    Dir.mkdir(File.dirname(file)) unless File.directory?(File.dirname(file))
    body = File.read(file) if File.exist?(file)
    File.open(file, 'a', *args) do |f|
      yield body, f
    end
  end

  def remove_tags_file(dir_path)
    File.delete(tags_path) if File.exists?(tags_path)
  end

  def tags_file_name
    'tags'
  end

  def tags_path
    File.join current_dir, tags_file_name
  end

  def ignore
    "--languages=#{ignore_file_types}" if ignore_file_types
  end

  def ignore_file_types
    langs = ''
    IGNORE_FILES.each do |ft|
      langs << ',' unless langs.empty?
      langs << "-#{ft}"
    end
    langs
  end
end
