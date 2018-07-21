---
title: Go channels
teaser: Properties, internals and particularities of Go channels.
image: /images/logo.png
comments: true
category: programming
tags: [go]
---

## Definition
A channel is a circular queue that conveys values of a certain type either
synchronously or asynchronously. A channel can receive values from many
senders and send values to many receivers. Senders and receivers are subsets
of the program's goroutines.

<div class="image-container">
  <image src="/images/channel_many-to-many.png" alt="many-to-many"/>
</div>


## Terminology
Channels can be classified in four categories:

- *"Buffered"*: channels constructed with an inner buffer size greater than
1.
- *"Empty-buffered"*: channels constructed with an inner buffer size of 0.
- *"Nil"*: channels either explicitely (assignment) or implicitely
(uninitialized variable) set to the `nil` value.
- *"Unbuffered"*: channels constructed without an inner buffer size.


## Lifecycle
A channel is initialized by calling `make()`. This invocation takes either
one or two arguments depending on the kind of channel being created. The
first argument is mandatory, it indicates the channel's element type, the
second argument is the inner buffer size, only required for buffered
channels.

A channel is closed by calling `close()`. Closing a channel is optionnal,
it's the way for senders to inform receivers that the channel will not
receive values anymore.

### Declaration
```go
// At this point c is a nil channel.
var c chan int
```

### Initialization
```go
// Unbuffered channel
c = make(chan int)

// Buffered channel
c = make(chan int, 2)

// Empty-buffered channel
c = make(chan int, 0)
```

### Termination
```go
close(c)
```

##### Pitfalls:
- An attempt to close a nil channel triggers a panic.
- An attempt to close a closed channel triggers a panic.


## Channel operator
The operator used to interact with a channel is `<-`. It is used to either
send a value to a channel or receive a value from it, the operation type
depends on the place of the operator with regard to the channel variable.

### Receive operation
```go
// Attemp to read a value from the channel.
value := <- c

// Attempt to read a value from the channel that also gets
// information about whether the channel is closed or not
// (ok is false if the channel is closed).
value, ok := <- c


// Attempt to read channel values until the channel is closed.
for value := range c {
    // do something
}

```

### Send operation
```go
c <- value
```

##### Pitfalls:
- A receive operation on a closed channel is always non-blocking.
- The value received from a closed channel is the channel's element type zero value.


## Channel types
The channel operator takes another signification when writing a channel's
type as a function argument (or return argument): it defines unidirectional
channels i.e. *"receive-only"* and *"send-only"* channels.

### Receive-only channel
```go
arg <- chan int
```

### Send-only channel
```go
arg chan <- int
```

### Example
```go
package main

func getRcvOnlyChan() <- chan int {
    return make(chan int)
}

func main() {
    c := getRcvOnlyChan()
    c <- 1
}
```
```
invalid operation: c <- 1 (send to receive-only type <-chan int)
```

##### Pitfalls:
- An unidirectional channel can't be converted back to a bidirectional channel.


## Characteristics
### Unbuffered and empty-buffered channels
Such channels *synchronously* transmits one typed element between a sender and
a receiver. In other words, sending a value blocks the sender's execution until
a receiver is ready to read the element. Respectively, receiving a value blocks
the receiver's execution until a sender is ready to send a value. The value is
transmitted by copying directly to the *receiver's stack*.

### Buffered channels
A buffered channel transmits one typed element between a sender and a receiver,
either:
- *Asynchronously*, if the buffer has remaining free space.
- *Synchronously*, if the buffer is full.

### Nil channels
Sending to a nil channel or receiving from a nil channel is an indefinitely
blocking operation.

So, can it even be useful ? The answer is yes, it can be of interest when
selecting channels in a situation where closed channels appear whereas active
channels remain. At this point, processor time may be wasted reading zero
values from closed channels. Transitionning from closed channels to nil
channels make sure this doesn't happen.

## Selecting channels
As we have discovered, channel operations may be blocking either because of
the nature of the channel or because the queue is full. So how do we write
goroutines that operate on one-to-many channels without seeing their
execution stopped by a particular channel all the time ? This is where the
`select` statement chimes in. This statement blocks until at least one of its
branch can execute. If multiple branches are eligible for execution, one is
picked in a non-deterministic manner.

To terminate the execution of the statement from one of its branch, use `break`.

### Example

```go
package main

import "fmt"

func main() {
    a := make(chan int)
    b := make(chan int)

    go func() {
        select {
        case val := <-a:
            fmt.Println("Received from a:", val)
        case val := <-b:
            fmt.Println("Received from b:", val)
        }
    }()

    b <- 0
}
```
```
Received from b: 0
```

##### Pitfalls:
- As it's very common to enclose channel selection within loops, keep in mind
`break` terminates the execution of the *innermost* `for`, `select` or
`switch` statement.

<br/>
<br/>
I hope Go channels have no more secrets for you after this reading!