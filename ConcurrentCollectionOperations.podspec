Pod::Spec.new do |s|
  s.name         = "ConcurrentCollectionOperations"
  s.version      = "0.0.1"
  s.summary      = "Concurrent map and filter on NSArray, NSDictionary, NSSet using GCD."
  s.description  = <<-DESC
    This is a set of categories for performing concurrent map and filter
    operations on Foundation data structures, currently NSArray, NSDictionary,
    NSSet.

    Concurrency is achieved using Grand Central Dispatch's dispatch_apply. By
    default, operations are run on the default priority global concurrent queue
    (DISPATCH_QUEUE_PRIORITY_DEFAULT). The operations can be performed on any
    concurrent queue, see the category header files.
  DESC
  s.homepage     = "https://github.com/kastiglione/ConcurrentCollectionOperations"
  s.license      = 'MIT'
  s.authors      = { "Dave Lee" => "dave@kastiglione.com", "Eloy Durán" => "eloy@fngtps.com", "Mateus Armando" => "seanlilmateus@yahoo.de" }
  s.source       = { :git => "https://github.com/kastiglione/ConcurrentCollectionOperations.git", :tag => "v0.0.1" }
  s.source_files = 'ConcurrentCollectionOperations'
  s.requires_arc = true
end
