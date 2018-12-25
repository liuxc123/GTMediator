Pod::Spec.new do |s|
  s.name             = 'GTMediator'
  s.version          = '0.0.3'
  s.summary          = 'A short description of GTMediator.'
  s.homepage         = 'https://github.com/liuxc123/GTMediator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuxc123' => 'lxc_work@126.com' }
  s.source           = { :git => 'https://github.com/liuxc123/GTMediator.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'GTMediator/Classes/**/*'
end
