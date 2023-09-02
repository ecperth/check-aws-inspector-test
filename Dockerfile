FROM amazonlinux:2023

# Use a dummy file to invalidate the cache
ADD somefile.txt /tmp/