library throttled;

typedef ThrottleCallback = void Function();

Map<String, ThrottleFunction> _throttleFunctions = <String, ThrottleFunction>{};

ThrottleFunction? removeThrottle(String id) => _throttleFunctions.remove(id);

void throttle(String id, ThrottleCallback runner,
    {bool leaky = false,
    Duration cooldown = const Duration(milliseconds: 250)}) {
  _throttleFunctions.putIfAbsent(
      id,
      () => leaky
          ? _LeakingThrottleFunction(cooldown, runner)
          : ThrottleFunction(cooldown, runner));
  _throttleFunctions[id]!.runner = runner;
  _throttleFunctions[id]!();
}

class ThrottleFunction {
  final Duration cooldown;
  ThrottleCallback runner;
  int cid = 0;

  ThrottleFunction(this.cooldown, this.runner);

  void call() {
    cid++;
    int l = cid;
    Future.delayed(cooldown, () {
      if (cid == l) {
        runner();
      }
    });
  }

  void force() {
    runner();
  }
}

class _LeakingThrottleFunction extends ThrottleFunction {
  int lastCall = 0;

  _LeakingThrottleFunction(Duration cooldown, ThrottleCallback runner)
      : super(cooldown, runner);

  @override
  void call() {
    cid++;
    int l = cid;

    if (DateTime.now().millisecondsSinceEpoch - lastCall >
        cooldown.inMilliseconds) {
      runner();
      lastCall = DateTime.now().millisecondsSinceEpoch;
    } else {
      Future.delayed(cooldown, () {
        if (cid == l) {
          runner();
          DateTime.now().millisecondsSinceEpoch;
        }
      });
    }
  }
}
