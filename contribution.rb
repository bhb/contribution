# Usage:
# ruby contribution.rb [author] [path ...]

author = ARGV.shift

paths = []
while (path=ARGV.shift)
  paths << path
end

puts "Looking for contributions by #{author} in #{paths.inspect}"

patterns = []
paths.each do |path|
  patterns << File.expand_path(File.join(path, "**", "*.rb"))
  patterns << File.expand_path(File.join(path, "**", "*.erb"))
end

puts "Looking for files matching the following patterns:"

patterns.each do |pattern|
  puts pattern
end

puts "------------"
puts "Working ...."

results = []
files = patterns.map { |pattern| Dir.glob(pattern) }.flatten
files.each do |filename|
  puts filename
  total_lines = File.readlines(filename).length
  git_command = "git blame -w #{filename} | grep '#{author}' | wc -l"
  author_lines = `#{git_command}`.to_i
  percentage = (author_lines.to_f/total_lines)
  results << [percentage, filename, total_lines]
end

puts "Files most contributed to by #{author}"
longest_filename_length = files.map{|filename| filename.length}.max
results.sort.reverse.each do |percentage, filename, total_lines|
  puts "%6.2f%% %-#{longest_filename_length}s (%-4d total lines)" % [percentage*100, filename, total_lines] if percentage > 0
end
puts "(All other files had 0% contribution by #{author})"
