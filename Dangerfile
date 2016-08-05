fail("Jekyll failed to build site") unless system("bundle exec jekyll build")
fail("Bad HTML generated") unless system("bundle exec htmlproofer ./_site")

system("bundle exec rake verify_data")

messages = {
  1 => "Incomplete event data",
  2 => "Events out of order"
}

if message = messages[$?.exitstatus]
  fail message
end
