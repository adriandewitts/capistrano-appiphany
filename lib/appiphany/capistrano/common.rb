def _cset(name, *args, &block)
  unless exists?(name)
    set(name, *args, &block)
  end
end

def remote_file_exists?(path)
  'true' == capture("if [ -e #{path} ]; then echo 'true'; fi").strip
end

