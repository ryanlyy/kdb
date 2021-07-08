Supervisor Note
---

- [SIGTERM](#sigterm)

# SIGTERM

When supervisord recevies SIGTERM, it will change its state to  SHUTDOWN and fire Supervisor Event as  SHUTDOWN, then it will call stopall(kill TERM) to all its child process.

options.py:
```python
    def setsignals(self):
        receive = self.signal_receiver.receive
        signal.signal(signal.SIGTERM, receive)
        signal.signal(signal.SIGINT, receive)
        signal.signal(signal.SIGQUIT, receive)
        signal.signal(signal.SIGHUP, receive)
        signal.signal(signal.SIGCHLD, receive)
        signal.signal(signal.SIGUSR2, receive)
```

```python
        priority = integer(get(section, 'priority', 999))
        autostart = boolean(get(section, 'autostart', 'true'))
        autorestart = auto_restart(get(section, 'autorestart', 'unexpected'))
        startsecs = integer(get(section, 'startsecs', 1))
        startretries = integer(get(section, 'startretries', 3))
        stopsignal = signal_number(get(section, 'stopsignal', 'TERM'))
        stopwaitsecs = integer(get(section, 'stopwaitsecs', 10))
        stopasgroup = boolean(get(section, 'stopasgroup', 'false'))
        killasgroup = boolean(get(section, 'killasgroup', stopasgroup))
        exitcodes = list_of_exitcodes(get(section, 'exitcodes', '0'))
        # see also redirect_stderr check in process_groups_from_parser()
        redirect_stderr = boolean(get(section, 'redirect_stderr','false'))
        numprocs = integer(get(section, 'numprocs', 1))
        numprocs_start = integer(get(section, 'numprocs_start', 0))
        environment_str = get(section, 'environment', '', do_expand=False)
        stdout_cmaxbytes = byte_size(get(section,'stdout_capture_maxbytes','0'))
```

```python
class SignalReceiver:
    def __init__(self):
        self._signals_recvd = []

    def receive(self, sig, frame):
        if sig not in self._signals_recvd:
            self._signals_recvd.append(sig)

    def get_signal(self):
        if self._signals_recvd:
            sig = self._signals_recvd.pop(0)
        else:
            sig = None
        return sig

```

```python
    def handle_signal(self):
        sig = self.options.get_signal()
        if sig:
            if sig in (signal.SIGTERM, signal.SIGINT, signal.SIGQUIT):
                self.options.logger.warn(
                    'received %s indicating exit request' % signame(sig))
                self.options.mood = SupervisorStates.SHUTDOWN

```

```python
def runforever(self):
    ...
    while 1:
        ...
        if self.options.mood < SupervisorStates.RUNNING:
            if not self.stopping:
                # first time, set the stopping flag, do a
                # notification and set stop_groups
                self.stopping = True
                self.stop_groups = pgroups[:]
                events.notify(events.SupervisorStoppingEvent())

                self.ordered_stop_groups_phase_1()
        ...
        self.handle_signal()
        ...
    ...
```

Sending SIGTERM
```python
    def stop(self):
        """ Administrative stop """
        self.administrative_stop = True
        self.laststopreport = 0
        return self.kill(self.config.stopsignal)

```

stop all child process started by supervisord
```python
    def stop_all(self):
        processes = list(self.processes.values())
        processes.sort()
        processes.reverse() # stop in desc priority order

        for proc in processes:
            state = proc.get_state()
            if state == ProcessStates.RUNNING:
                # RUNNING -> STOPPING
                proc.stop()
            elif state == ProcessStates.STARTING:
                # STARTING -> STOPPING
                proc.stop()
            elif state == ProcessStates.BACKOFF:
                # BACKOFF -> FATAL
                proc.give_up()
```

```python
    def ordered_stop_groups_phase_1(self):
        if self.stop_groups:
            # stop the last group (the one with the "highest" priority)
            self.stop_groups[-1].stop_all()
```

