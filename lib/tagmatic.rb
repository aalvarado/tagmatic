class TagMatic
  VERSION = '0.0.3'

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

  HOOK_TEMPLATE = 'tagmatic generate-tags .'
  HELP = 'Run `tagmatic install` to setup the hooks that regenerate your "tags" file.'

  attr_accessor :current_dir

  def initialize(*argv)
    command = argv.shift
    command = command.tr('-', '_') if command

    if command && respond_to?(command) && argv.any?
      send(command, argv)
    elsif command && respond_to?(command)
      send(command)
    else
      puts 'Command not found'
      help
    end
  end

  def install
    HOOKS_FILES.each do |file_name|
      append(File.join(git_dir, 'hooks', file_name), 0777) do |body, f|
        [HASH_BANG, HOOK_TEMPLATE].each do |text|
          f.puts(text) unless body && body.include?(text)
        end
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
      unless $CHILD_STATUS.to_i == 0
        raise RuntimeError, result
      end
    end
  end

  def help
    puts HELP
  end

  def __version
    puts VERSION
  end

  protected

  def git_dir
    @git_dir ||= %x[git rev-parse --git-dir].chomp
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
    [ '-', IGNORE_FILES.join(',-') ].join if IGNORE_FILES.any?
  end
end
