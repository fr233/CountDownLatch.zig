const std = @import("std");


pub const CountDownLatch = struct {
    state: i32,
    resetEvent: std.ResetEvent,
    
    pub fn init(count: i32) CountDownLatch {
        return CountDownLatch{.state = count, .resetEvent = std.ResetEvent.init()};
    }
    
    
    pub fn countDown(self: *CountDownLatch) void {
        @fence(.Release);
        var state = self.state;
        
        while(true){
            if(state <= 0){
                return;
            }
            var o = @cmpxchgWeak(i32, &self.state, state, state - 1, .Acquire, .Monotonic);
            if(o)|v|{
                state = v;
                continue;
            }
            break;
        }
        if((state - 1) == 0){
            self.resetEvent.set();
            self.resetEvent.deinit();
        }
    }
    
    pub fn wait(self: *CountDownLatch) void {
        while(@atomicLoad(i32, &self.state, .Acquire) > 0) {
            self.resetEvent.wait();
        }
    }
    
    pub fn timedWait(self: *CountDownLatch, timeout_ns: u64) !void {
        while(@atomicLoad(i32, &self.state, .Acquire) > 0) {
            if(self.resetEvent.timedWait(timeout_ns)) |_| {} else |err| {
                return err;
            }
        }
    }
    

};


