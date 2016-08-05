fail("Jekyll failed to build site") unless system("bundle exec jekyll build")
fail("Bad HTML generated") unless system("bundle exec htmlproofer ./_site")
