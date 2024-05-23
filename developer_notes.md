# Developer Notes

This is a living document. The goal for this Developer Notes is to document the
design, conventions, architectural decisions made in the development of this
application and some of the reasons behind them.

## Architecture

The app consists of the backend and frontend. Diligent is the backend and is written so that the "domain" logic can be tested without touching the UI. Ideally, the frontend should only reflect the state of the domain and make changes to the domain through Diligent itself.

### Explicit Dependencies

There are subtle dependencies




### Dependency Injection


