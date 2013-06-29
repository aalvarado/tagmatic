class TagOMatic
  VERSION = "0.0.1"

  HASH_BANG = "#!/bin/bash"
  TAGS_FILE_NAME = "tags"
  TAGOMATIC_BIN = 'tagomatic'

  TEMPLATE = <<-TMPL
#{TAGOMATIC_BIN} generate-tags .
TMPL

  CTAGS_CMD = 'ctags -Ra'
  LANGUAGES_FLAGS = '--languages='
  APP_DIRECTORIES = [
    'app',
    'config',
    'lib'
  ]

  IGNORE_FILES = [
    'javascript',
    'sql'
  ]

  HELP = <<-HELP
run install to install to hooks to regenerate your tags file
HELP

  attr_accessor :current_dir

  def initialize *argv
    command = argv.shift
    command = command.tr('-', '_') if command

    if command && respond_to?( command )
      send( command, argv )
    else
      display_help
    end
  end

  def git_dir
    @git_dir = %x[git rev-parse --git-dir].chomp
    @git_dir
  end

  def install *argv
    append(File.join(git_dir, 'hooks', 'post-checkout'), 0777) do |body, f|
      f.puts HASH_BANG unless body
      f.puts TEMPLATE
    end
    puts 'all tagged up'
  end

  def display_help
    puts HELP
  end

  def tags_file_name
    TAGS_FILE_NAME
  end

  def append(file, *args)
    Dir.mkdir(File.dirname(file)) unless File.directory?(File.dirname(file))
    body = File.read(file) if File.exist?(file)
    File.open(file, 'a', *args) do |f|
      yield body, f
    end
  end

  def generate_tags dir_path
    puts 'Regenerating tags...'
    self.current_dir = File.expand_path( dir_path.pop )
    remove_tags_file( dir_path )
    APP_DIRECTORIES.each do |path|
      result = `#{CTAGS_CMD} #{ignore} #{path}` if File.exists?( path )
    end
  end

  def remove_tags_file dir_path
    File.delete( tags_path ) if File.exists?( tags_path )
  end

  def tags_path
    File.join current_dir, tags_file_name
  end

  def ignore
    "#{LANGUAGES_FLAGS}#{ignore_file_types}" if ignore_file_types
  end

  def ignore_file_types
    langs = ''
    IGNORE_FILES.each do |ft|
      langs << "," unless langs.empty?
      langs << "-#{ft}"
    end
    langs
  end

  protected :append
end
