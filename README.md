# CountDownLatch.zig
CountDownLatch for zig

# how to use
```
const CountDownLatch = @import("./CountDownLatch.zig").CountDownLatch;
....
one thread:
var latch = CountDownLatch.init(1);
doSomeThing();
latch.countDown();



other threads:
latch.wait();
```


# example code
```
fn example(context: *CountDownLatch) !void {
    const stdout = std.io.getStdOut().writer();
    if(context.timedWait(10000000000)) |_| {
        try stdout.print("{}\n", .{"latched"});
    } else |err|{
        try stdout.print("{}\n", .{"timeout"});
    }
}
pub fn main() !void {
    var latch = CountDownLatch.init(1);
    var a:[10]*std.Thread = undefined;
    for(a)|*item, idx|{
        item.* = std.Thread.spawn(&latch, example) catch unreachable;
    }
    std.time.sleep(2000000000);
    latch.countDown();
    for(a)|item, idx|{
        item.wait();
    }
}
```
