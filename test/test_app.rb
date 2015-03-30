#STDOUT.sync = true

puts "Starting up test app."

index = 0
while true
  4.times do
    print '.'
    sleep 0.5
  end
  puts "\nSTDOUT: #{Time.now}"
  sleep 2
  STDERR.puts "STDERR: #{Time.now}"
end
