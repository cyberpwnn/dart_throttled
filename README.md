Throttle function calls with the ability to ensure the last trigger will eventually call the callback (leaky)

## Features

Throttle functions are not delays, they work like cooldowns. Calling it once happens immediately, calling it again will within the cooldown will not trigger the callback. Calling it again after the cooldown will trigger the callback again. The last call will always trigger the callback after the delay if leaky is set to true.

## Usage

Given the example

```dart
import 'package:throttle/throttle.dart';

int state = 0;

Future<void> run() async
{
    while(state < 1000) {
        await Future.delayted(Duration(milliseconds: 100), () {});
        state++;
        throttle(() => updateState(), 
            cooldown: Duration(seconds: 1), 
            leaky: true);
    }
}

void updateState(){
    print('State pushed: $state');
}
```

The results will print as
```
State pushed: 1
State pushed: 11
State pushed: 21
...
State pushed: 991
State pushed: 1000
```

Since leaky is turned on, the last call will eventually run.