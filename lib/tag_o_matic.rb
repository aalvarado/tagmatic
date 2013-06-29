class TagOMatic
  VERSION = "0.0.1"

  TEMPLATE = <<-TMPL
    #!/bin/bash
    cd ..
    rm tags
    ctags -Ra app
    ctags -Ra config
    ctags -Ra lib
  TMPL

  def initialize *argv
    command = argv.shift.tr('-', '_')

    if respond_to? command
      send( command, argv )
    else
      display_help
    end
  end

  def git_dir
    @git_dir ||= %x[git rev-parse --git-dir].chomp
  end

  def install
    append(File.join(git_dir, 'hooks', 'post-checkout'), 0777) do |body, f|
      f.puts TEMPLATE
    end
  end

end
