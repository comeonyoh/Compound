# Compound
Let's do tasks asynchronously and sequentially

## A problem what I want to solve

To be honest, sometimes I had written codes like this.
```swift
task1.doTask = {
    
    task2.doTask = {
        
        task3.doTask = {
        
        }
    }
}
```

As you can see, this code have some problems.

* It's messy. This code can be longer and the indentions are so complicated.
* Not maintainable and hard to reuse blocks.


## The Goal
* Write codes for asynchronous and sequential tasks easily
* Easy to reuse and maintainable
* Easy to test a task

## Examples

```
let queue = RequestQueue { (queue, error) in
    //  All tasks completed
}
        
let requestA = Request()
let requestB = Request()
let requestC = Request()

requestA.task = {
    //  Write your first task code.
    $0.finish()
}

requestB.task = {
    //  Write your second task code.
    $0.finish()
}

requestC.task = {
    //  Write your third task code.
    $0.finish()
}

queue.addOperations([requestA, requestB, requestC])

```


## Technologies
* [Operation](https://developer.apple.com/documentation/foundation/operation)
* [OperationQueue](https://developer.apple.com/documentation/foundation/operationqueue)
