system('bundle exec rake')

messages = {
  1 => 'Jekyll failed to build site',
  2 => 'htmlproofer found errors',
  3 => 'Incomplete event data found',
  4 => 'Events out of order',
  5 => 'Limit commit subject line to 50 characters'
}

if message = messages[$?.exitstatus]
  fail message
end

for commit in git.commits
  subject = commit.message.split("\n").first
  fail messages[5] if subject.length > 50
end
