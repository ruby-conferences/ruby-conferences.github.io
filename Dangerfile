error_messages = {
  1 => 'Jekyll failed to build site',
  2 => 'htmlproofer found errors',
  3 => 'Incomplete event data found',
  4 => 'Invalid event data found',
  5 => 'Events out of order',
  6 => 'Limit commit subject line to 50 characters',
  7 => 'No period at end of commit subject',
  8 => 'Separate subject from body with newline',
}

system 'bundle exec rake'

fail message if message = error_messages[$?.exitstatus]

for commit in git.commits
  (subject, empty_line, *body) = commit.message.split("\n")
  fail error_messages[6] if subject.length > 50
  fail error_messages[7] if subject.split('').last == '.'
  fail error_messages[8] if empty_line && empty_line.length > 0
end
