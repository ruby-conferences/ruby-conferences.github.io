error_messages = {
  1 => 'Jekyll failed to build site',
  2 => 'htmlproofer found errors',
  3 => 'Incomplete event data found',
  4 => 'Invalid event data found',
  5 => 'Events out of order'
}

system 'bundle exec rake build verify_data'

fail message if message = error_messages[$?.exitstatus]

commit_lint.check
