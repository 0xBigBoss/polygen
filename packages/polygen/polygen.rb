require 'pathname'

POLYGEN_CONFIG_NAMES = [
  'polygen.config.js',
  'polygen.config.mjs',
  'polygen.config.cjs',
].freeze

def polygen_find_project_root(from_dir)
  dir = Pathname.new(from_dir).expand_path
  loop do
    return dir if POLYGEN_CONFIG_NAMES.any? { |name| dir.join(name).exist? }
    return dir if dir.join('package.json').exist?

    parent = dir.parent
    break if parent == dir
    dir = parent
  end

  nil
end

def polygen_find_binary(from_dir)
  dir = Pathname.new(from_dir).expand_path
  loop do
    candidate = dir.join('node_modules/.bin/polygen')
    return candidate if candidate.exist?

    parent = dir.parent
    break if parent == dir
    dir = parent
  end

  nil
end

def install_polygen()
  install_root = Pod::Config.instance.installation_root
  project_root = polygen_find_project_root(install_root) || install_root
  polygen_bin = polygen_find_binary(project_root) || polygen_find_binary(install_root)

  if polygen_bin.nil?
    raise 'polygen CLI not found in node_modules/.bin. Run yarn install first.'
  end

  pre_install do |_installer|
    Dir.chdir(project_root) do
      ok = system(polygen_bin.to_s, 'generate')
      raise 'polygen generate failed' unless ok
    end
  end

  pod 'ReactNativeWebAssemblyHost',
      :path => project_root.join('node_modules/.polygen-out/host').to_s
#   pod 'ReactNativePolygen/Runtime'
end
