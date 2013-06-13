## Concurrent Collection Operations

This is a set of categories for performing concurrent map and filter operations
on Foundation data structures, currently supported are `NSArray`,
`NSDictionary`, `NSSet`, `NSOrderedSet`, and `NSMapTable` (currently supported
on OS X only).

Concurrency is achieved using Grand Central Dispatch's `dispatch_apply`. By
default, operations are run on the default priority global concurrent queue
(`DISPATCH_QUEUE_PRIORITY_DEFAULT`). The operations can be performed on any
concurrent queue, see the category header files.

This library is based off code and ideas from [@alloy](https://github.com/alloy)
and [@seanlilmateus](https://github.com/seanlilmateus). It has been created
because we were unaware of an existing implementation.

### Installation

Install via [CocoaPods](http://cocoapods.org/), or by adding the Xcode project
to your project.

### Examples

These examples are taken from the [tests](https://github.com/kastiglione/ConcurrentCollectionOperations/blob/master/ConcurrentCollectionOperationsTests/ConcurrentCollectionOperationsTests.m).

Doubling the values of an array:

```objc
    NSArray *doubled = [numbersArray cco_concurrentMap:^(NSNumber *number) {
        return @(2 * number.unsignedIntegerValue);
    }];
```

Filtering even numbers out of a dictionary:

```objc
    NSDictionary *filtered = [numbersDictionary cco_concurrentFilter:^BOOL (NSNumber *number) {
        return number.unsignedIntegerValue % 2 == 1;
    }];
```

### Contributors

ConcurrentCollectionOperations has been made by [@alloy](https://github.com/alloy),
[@CodaFi](https://github.com/CodaFi), [@jballanc](https://github.com/jballanc),
[@kastiglione](https://github.com/kastiglione), and
[@seanlilmateus](https://github.com/seanlilmateus).

### TODO

1. Write heavier/stressing tests.

### License

Concurrent Collection Operations is released under the MIT License. See
[LICENSE.txt](https://github.com/kastiglione/ConcurrentCollectionOperations/blob/master/LICENSE.txt).

### Contributing

1. Fork it
1. Create your feature branch (git checkout -b my-new-feature)
1. Commit your changes (git commit -am 'Add some feature')
1. Push to the branch (git push origin my-new-feature)
1. Create new Pull Request
