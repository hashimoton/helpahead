# coding: utf-8
#--
# Helpahead, 0.1.0
# Parse command line options based on help-like comments.
# 
# Usage: helpahead [options] [FILE]
#   -c         check FILE
#      --long-option
#   -u,--user  user name
# 
# The usage and options above are dummies, just to show how this script works.
#--
#

require "optparse"


class HelpAhead

  def initialize
    @comment_delim = '#'
    @help_begin = '--'
    @help_end = '--'
  end
  
  def extract_help_lines(source_file)
    help_lines = []
    is_help_found = false
    
    File.open(source_file) do |file|
      file.each_line do |line|

        if line.start_with?(@comment_delim)
          line.sub!('#', "");

          if !is_help_found && line.start_with?(@help_begin)
            is_help_found = true
          elsif is_help_found
            if line.start_with?(@help_end)
              break
            else
              help_lines.push(line)
            end
          end
        end
      end
    end
    
    return help_lines
  end


  def parse_line(line)
    defs = {}
    
    line.strip!
    
    if line =~ /,\s+([0-9]\.[0-9]\.[0-9])/
      defs[:version] = $~[1]
    end
    
    fields = line.split(/\s+/)
    fields.each do |field|
      if field.start_with?('-')
        option_count = 0
        field.split(',').each do |option|
          option_count += 1
          if option.start_with?("--")
            defs[:long] = option
          else
            defs[:short] = option
          end
        end
        
        defs[:desc] = fields.drop(option_count).join(' ')
      end
    end
    
    return defs
  end
  
  
  def parse(file, argv)
    options = {}
    
    help_lines = extract_help_lines(file)
    
    OptionParser.new do |opt|

      help_lines.each do |line|
        defs = parse_line(line)
        if defs[:version]
           opt.banner = line.strip
           opt.version = defs[:version]
        elsif defs[:short] || defs[:long]
          opt.on(defs[:short], defs[:long], defs[:desc]) do |v|
            if defs[:long]
              name = defs[:long]
            else
              name = defs[:short]
            end
            options[name] = v
          end
        else
          opt.on(line.strip)
        end
      end
      opt.parse!(argv)
    end
    return options
  end

end

#### EXAMPLE ####

if __FILE__ == $PROGRAM_NAME
  options = HelpAhead.new.parse(__FILE__, ARGV)
  p options
  p ARGV
end

# EOF
