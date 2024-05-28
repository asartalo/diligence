# Developer Notes

This is a living document. The goal for this Developer Notes is to document the
design, conventions, architectural decisions made in the development of this
application and some of the reasons behind them. These may change over time and
this document should be updated accordingly.

The notes and guidelines noted here may not reflect the current state of the
code but the ideals it tries to aspire to. And because ideas change, there will
be contradictions. It's important to point them out but also to realize that the
decisions that lead to them are products of changing ideas and aspirations.

## Architecture

The app consists of the backend and frontend. Diligent is the backend and is
written so that the "domain" logic can be tested without touching the UI.
Ideally, the frontend should only reflect the state of the domain and make
changes to the domain through Diligent itself.

### Dependency Injection

Currently, the codebase manages dependencies through a simple strategy inspired
by [DIY-ID](https://blacksheep.parry.org/archives/diy-di). See `di.dart`.

### Explicit Dependencies

There are subtle dependencies that can sometimes creep into our code. We try to
be explicit with these dependencies.

Examples:

- Instead, of using `DateTime.now()` and time and timing dependent functions
like the `Timer.timer()` and `Timer.periodic()` directly, we wrap these
functions into one coherent `Clock` class and let objects that need them use the
clock instance sometimes in their dependencies and sometimes in factories that
need to be instantiated with `DateTime` objects. This makes unit tests and
integration tests really easy. See `StubClock` and its usage in the codebase.
- The same for using `Fs` as a wrapper for filesystem access.

## Conventions

Prefer to return `Result<T, E>` instead of raising exceptions, errors.
