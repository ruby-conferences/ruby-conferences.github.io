system('bundle exec rake')

messages = {
  1 => 'Jekyll failed to build site',
  2 => 'htmlproofer found errors',
  3 => 'Incomplete event data found',
  4 => 'Events out of order'
}

if message = messages[$?.exitstatus]
  fail message
end
