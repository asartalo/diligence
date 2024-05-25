# Developer Notes

This is a living document. The goal for this Developer Notes is to document the
design, conventions, architectural decisions made in the development of this
application and some of the reasons behind them. These may change over time and
this document should be updated accordingly.

The notes and guidelines noted here may not reflect the current state of the
code but the idea is evolve the code to be closer to it. Also,

## Architecture

The app consists of the backend and frontend. Diligent is the backend and is
written so that the "domain" logic can be tested without touching the UI.
Ideally, the frontend should only reflect the state of the domain and make
changes to the domain through Diligent itself.

### Explicit Dependencies

There are subtle dependencies


### Dependency Injection


## Conventions

Prefer to return `Result<T, E>` instead of raising exceptions, errors.
