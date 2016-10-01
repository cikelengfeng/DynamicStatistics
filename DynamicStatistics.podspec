Pod::Spec.new do |s|
  s.name         = 'DynamicStatistics'
  s.version      = '1.0.1'
  s.summary      = 'dynamic statistics tool for iOS'

  s.description  = '<<-DESC
                   dynamic statistics tool for iOS
                   DESC'

  s.homepage     = 'https://github.com/cikelengfeng'
  s.license      = {:type => 'MIT',
                   :file => 'LICENSE'}
  s.authors       = {'cikelengfeng'=>'cikelengfeng@gmail.com'}
  s.platform     = :ios,'7.0'
  s.source       = {:git => 'https://github.com/cikelengfeng/DynamicStatistics.git',
                   :tag => s.version}
  s.source_files = '**/*.{h,m}'
  s.requires_arc = true
end
