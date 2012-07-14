module CoreExtension
  Dir[File.join(File.expand_path(File.join('..', 'core_extension'), __FILE__), '**', '*.rb')].each do |f|
    require_dependency f
    extension_module = f.sub(/(.*)(core_extension.*)\.rb/,'\2').classify.constantize
    base_module = f.sub(/(.*core_extension.)(.*)\.rb/,'\2').classify.constantize
    base_module.module_exec { include extension_module }
  end
end