# Generic Instructions

When available, read up on README.md to familiarize yourself with what we're
doing and how we're doing it.

When developing python:

- you almost always probably need to prefix your command with `uv run`. See
  <https://docs.astral.sh/uv/> for reference.
- always prefer absolute imports over relative imports, e.g.
  `from foo.bar import Baz` instead of from `.bar import Baz`.
- Use type hints wherever possible, and avoid using `Any` and `cast` if
  possible.
- Use pytest for testing if testing.
- If working in a monorepo structure, most likely you will have to cd into the
  project directory for running things for a specific project
- If available, run the pre-commit hooks (dont actually commit, just run them).
