messages = {
  1 => 'Jekyll failed to build site',
  2 => 'htmlproofer found errors',
  3 => 'Incomplete event data found',
  4 => 'Events out of order',
  5 => 'Limit commit subject line to 50 characters',
  6 => 'No period at end of commit subject',
  7 => 'Separate subject from body with newline',
}

system 'bundle exec rake'

fail message if message = messages[$?.exitstatus]

for commit in git.commits
  (subject, empty_line, *body) = commit.message.split("\n")
  fail messages[5] if subject.length > 50
  fail messages[6] if subject.split('').last == '.'
  fail messages[7] if empty_line && empty_line.length > 0
end
